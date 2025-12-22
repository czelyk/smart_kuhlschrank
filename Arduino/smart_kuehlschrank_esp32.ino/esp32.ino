#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "HX711_ADC.h"
#include <time.h>
#include <Preferences.h> // ID'yi kaydetmek için

// ---- Bluetooth Kütüphaneleri ----
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// ===== AYARLAR =====
// --- WiFi Ayarları ---
#define WIFI_SSID     "Deneme"
#define WIFI_PASSWORD "12345678"

// --- Firebase Ayarları ---
#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81"

// --- HX711 Pinleri ---
#define SCK_PIN 6
#define P1_DOUT 4
#define P2_DOUT 5

// --- Diğer Ayarlar ---
#define STABILIZING_TIME 2000
#define SEND_INTERVAL_MS 30000UL
float CAL1 = 420.0;
float CAL2 = 420.0;

// ===== GLOBAL NESNELER VE DEĞİŞKENLER =====
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
HX711_ADC scale1(P1_DOUT, SCK_PIN);
HX711_ADC scale2(P2_DOUT, SCK_PIN);
Preferences preferences; // Hafıza yönetimi
String userId = ""; // Telefonda gelen User ID burada saklanacak
unsigned long lastSendTime = 0;

// --- Bluetooth için UUID'ler ---
#define BLE_SERVICE_UUID         "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define BLE_CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

// ===== PROTOTİPLER =====
void sendData(String id, float weight);
String getTimestamp();
void setupBLE();

// ======================================================
//               BLUETOOTH CALLBACK'LERI
// ======================================================

// UID geldiğinde çalışacak fonksiyon
class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      String receivedData = "";

      if (value.length() > 0) {
        for (int i = 0; i < value.length(); i++) {
          receivedData += value[i];
        }
        Serial.print(">>> Gelen Veri: ");
        Serial.println(receivedData);

        // Veri "UID:xxxxxxxx" formatında mı kontrol et
        if (receivedData.startsWith("UID:")) {
          String receivedUid = receivedData.substring(4);
          receivedUid.trim(); // Boşlukları temizle

          Serial.println("Kullanici ID'si alindi: " + receivedUid);
          
          // ID'yi hafızaya kaydet
          preferences.putString("user_id", receivedUid);
          Serial.println("ID hafizaya kaydedildi. Cihaz yeniden baslatiliyor...");

          delay(1000);
          ESP.restart(); // Kaydettikten sonra yeniden başlat
        }
      }
    }
};

// ======================================================
//                     ANA KURULUM (SETUP)
// ======================================================

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n\n=== AKILLI BUZDOLABI V2.0 BAŞLIYOR ===");

  // 1. HAFIZAYI KONTROL ET
  preferences.begin("smart-fridge", false); // "smart-fridge" adında bir alan aç
  userId = preferences.getString("user_id", ""); // "user_id" anahtarını oku, yoksa boş döndür

  // 2. MOD SEÇİMİ (KURULUM MU, VERİ GÖNDERME Mİ?)
  if (userId == "") {
    // EĞER ID YOKSA -> BLUETOOTH KURULUM MODU
    Serial.println("[MOD] Kullanici ID'si bulunamadi.");
    Serial.println("[MOD] Bluetooth Kurulum Modu baslatiliyor...");
    setupBLE();
    Serial.println("Telefondan baglanti bekleniyor...");
    // Kurulum modunda loop'a gitmez, burada bekler.
  } 
  else {
    // EĞER ID VARSA -> WIFI VERİ GÖNDERME MODU
    Serial.println("[MOD] Kayitli Kullanici ID'si bulundu: " + userId);
    Serial.println("[MOD] WiFi Veri Gonderme Modu baslatiliyor...");

    // WiFi Bağlantısı
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("WiFi'ye baglaniliyor");
    int counter = 0;
    while (WiFi.status() != WL_CONNECTED && counter < 20) {
      delay(500); Serial.print("."); counter++;
    }

    if(WiFi.status() != WL_CONNECTED) {
      Serial.println("\n[HATA] WiFi baglantisi kurulamadi. Yeniden denenecek.");
      return;
    }
    Serial.println("\n[OK] WiFi Baglandi! IP: " + WiFi.localIP().toString());
    
    // Zaman Sunucusu (NTP)
    configTime(0, 0, "pool.ntp.org");
    Serial.print("Zaman senkronize ediliyor");
    struct tm timeinfo;
    while (!getLocalTime(&timeinfo)) {
      Serial.print("."); delay(1000);
    }
    Serial.println("\n[OK] Zaman alindi.");

    // Firebase Yapılandırması
    config.api_key = API_KEY;
    auth.user.email = "esp32@auther.com"; // Bu sahte email/pass kalabilir, UID ile auth yapacağız
    auth.user.password = "esp32pass";
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    // Sensörleri Başlat
    scale1.begin(); scale1.start(STABILIZING_TIME, true); scale1.setCalFactor(CAL1);
    scale2.begin(); scale2.start(STABILIZING_TIME, true); scale2.setCalFactor(CAL2);

    Serial.println("\nSistem Hazir. Veri gonderimi basliyor...");
    lastSendTime = millis() - SEND_INTERVAL_MS; // İlk döngüde hemen göndermesi için
  }
}

// ======================================================
//                       ANA DÖNGÜ (LOOP)
// ======================================================
void loop() {
  // Eğer kurulum modundaysak (userId boşsa) loop'ta hiçbir şey yapma.
  if (userId == "") {
    delay(1000);
    return;
  }

  // ---- Veri Gönderme Modu ----
  scale1.update();
  scale2.update();

  if (millis() - lastSendTime >= SEND_INTERVAL_MS) {
    if (WiFi.status() == WL_CONNECTED) {
      float w1 = scale1.getData();
      float w2 = scale2.getData();

      Serial.println("\n>> Firebase'e veri gonderiliyor...");
      sendData("platform1", w1);
      sendData("platform2", w2);
    } else {
      Serial.println("\n[!] WiFi baglantisi yok, gonderilemiyor.");
    }
    lastSendTime = millis();
  }
}

// ======================================================
//                  YARDIMCI FONKSİYONLAR
// ======================================================

// Bluetooth Kurulumunu Başlatan Fonksiyon
void setupBLE() {
  BLEDevice::init("Smart Fridge ESP32");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(BLE_SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         BLE_CHARACTERISTIC_UUID_RX,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic->setCallbacks(new MyCallbacks());
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(BLE_SERVICE_UUID);
  BLEDevice::startAdvertising();
}

// Firebase'e Veri Gönderen Fonksiyon
void sendData(String id, float weight) {
  String json = "{\"fields\":{\"current_weight_kg\":{\"doubleValue\":" + String(weight, 2) + "},\"last_updated\":{\"timestampValue\":\"" + getTimestamp() + "\"}}}";
  String path = "users/" + userId + "/platforms/" + id; // Dinamik userId kullanılıyor

  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), json.c_str(), "current_weight_kg,last_updated")) {
    Serial.println("[OK] " + id + " -> " + String(weight, 2) + " kg");
  } else {
    Serial.println("[HATA] (" + id + "): " + fbdo.errorReason());
  }
}

// Zaman Damgası Oluşturan Fonksiyon
String getTimestamp() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return "2025-01-01T00:00:00Z"; 
  }
  char buf[32];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}
