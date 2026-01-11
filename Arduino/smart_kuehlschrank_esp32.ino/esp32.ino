#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "HX711.h"
#include <time.h>
#include <Preferences.h>

// ---- Bluetooth Kütüphaneleri ----
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// ===== AYARLAR =====
// WiFi ayarları artık hafızadan okunacak.
// #define WIFI_SSID     "Deneme"
// #define WIFI_PASSWORD "12345678"

#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81"

// --- HX711 Pinleri ---
#define SCK_PIN 6
#define P1_DOUT 4
#define P2_DOUT 5

// --- Diğer Ayarlar ---
#define SEND_INTERVAL_MS 30000UL
float CAL1 = 420.0;
float CAL2 = 420.0;

// ===== GLOBAL NESNELER VE DEĞİŞKENLER =====
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

HX711 scale1;
HX711 scale2;

Preferences preferences;
String userId = "";
unsigned long lastSendTime = 0;

#define BLE_SERVICE_UUID         "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define BLE_CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

// ===== PROTOTİPLER =====
void sendData(String id, float weight);
String getTimestamp();
void setupBLE();

// ====================================================== 
//               BLUETOOTH CALLBACK'LERI
// ======================================================

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      String receivedData = "";
      if (value.length() > 0) {
        for (int i = 0; i < value.length(); i++) receivedData += value[i];
        receivedData.trim();
        Serial.print(">>> Gelen Veri: "); Serial.println(receivedData);

        // --- UID AYARI ---
        if (receivedData.startsWith("UID:")) {
          String uid = receivedData.substring(4);
          preferences.putString("user_id", uid);
          Serial.println("Kullanıcı ID kaydedildi.");
        }
        // --- WIFI AYARI (WIFI:ssid;password) ---
        else if (receivedData.startsWith("WIFI:")) {
            String creds = receivedData.substring(5);
            int separator = creds.indexOf(';');
            if (separator != -1) {
                String ssid = creds.substring(0, separator);
                String pass = creds.substring(separator + 1);
                preferences.putString("wifi_ssid", ssid);
                preferences.putString("wifi_pass", pass);
                Serial.println("WiFi bilgileri kaydedildi. Cihaz yeniden başlatılıyor...");
                delay(1000);
                ESP.restart();
            }
        }
        // --- KALİBRASYON ---
        else if (receivedData == "CAL:ZERO") {
          scale1.tare(); scale2.tare();
        }
        else if (receivedData == "CAL:P1:800") {
          long reading = scale1.get_value(10);
          float newCal = (float)reading / 0.8f;
          scale1.set_scale(newCal);
          preferences.putFloat("cal1", newCal);
        }
        else if (receivedData == "CAL:P2:800") {
          long reading = scale2.get_value(10);
          float newCal = (float)reading / 0.8f;
          scale2.set_scale(newCal);
          preferences.putFloat("cal2", newCal);
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
  Serial.println("\n=== AKILLI BUZDOLABI (Dinamik WiFi) ===");

  // Hafızadan ayarları oku
  preferences.begin("smart-fridge", false); 
  userId = preferences.getString("user_id", "");
  CAL1 = preferences.getFloat("cal1", 420.0);
  CAL2 = preferences.getFloat("cal2", 420.0);
  String wifiSsid = preferences.getString("wifi_ssid", "");
  String wifiPass = preferences.getString("wifi_pass", "");

  // Bluetooth'u her zaman başlat
  setupBLE();

  // Sensörleri Başlat
  scale1.begin(P1_DOUT, SCK_PIN); scale2.begin(P2_DOUT, SCK_PIN);
  scale1.set_scale(CAL1);         scale2.set_scale(CAL2);
  scale1.tare();                  scale2.tare();

  // Sadece WiFi ve Kullanıcı ID'si varsa internete bağlan
  if (userId != "" && wifiSsid != "") {
    WiFi.mode(WIFI_STA);
    WiFi.begin(wifiSsid.c_str(), wifiPass.c_str());
    Serial.print("WiFi'ye baglaniliyor: " + wifiSsid);
    int counter = 0;
    while (WiFi.status() != WL_CONNECTED && counter < 20) {
      delay(500); Serial.print("."); counter++;
    }

    if(WiFi.status() == WL_CONNECTED) {
      Serial.println("\n[OK] WiFi Baglandi!");
      configTime(0, 0, "pool.ntp.org");
      config.api_key = API_KEY;
      auth.user.email = "esp32@auther.com";
      auth.user.password = "esp32pass";
      Firebase.begin(&config, &auth);
      Firebase.reconnectWiFi(true);
    } else {
      Serial.println("\n[HATA] WiFi baglantisi kurulamadi.");
    }
  } else {
      if (userId == "") Serial.println("[BILGI] Kullanıcı ID'si ayarlanmamış.");
      if (wifiSsid == "") Serial.println("[BILGI] WiFi bilgileri ayarlanmamış.");
  }

  Serial.println("Sistem Hazir.");
  lastSendTime = millis() - SEND_INTERVAL_MS;
}

// ... (loop ve diğer yardımcı fonksiyonlar aynı kalır) ...
void loop() {
  if (userId != "" && millis() - lastSendTime >= SEND_INTERVAL_MS) {
    if (WiFi.status() == WL_CONNECTED) {
      float w1 = scale1.get_units(10); 
      float w2 = scale2.get_units(10);
      if (w1 < 0) w1 = 0; if (w2 < 0) w2 = 0;
      sendData("platform1", w1);
      sendData("platform2", w2);
    }
    lastSendTime = millis();
  }
}

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
  BLEDevice::startAdvertising();
}

void sendData(String id, float weight) {
  String json = "{\"fields\":{\"current_weight_kg\":{\"doubleValue\":" + String(weight, 2) + "},\"last_updated\":{\"timestampValue\":\"" + getTimestamp() + "\"}}}";
  String path = "users/" + userId + "/platforms/" + id;
  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), json.c_str(), "current_weight_kg,last_updated")) {
    Serial.println("[OK] " + id + " -> " + String(weight, 2) + " kg");
  } else {
    Serial.println("[HATA]: " + fbdo.errorReason());
  }
}

String getTimestamp() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return "2025-01-01T00:00:00Z"; 
  char buf[32];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}
