#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "HX711_ADC.h"
#include <time.h>

// ===== WIFI AYARLARI =====
#define WIFI_SSID     "Deneme"
#define WIFI_PASSWORD "12345678"

// ===== FIREBASE AYARLARI =====
#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81"
#define USER_ID "8SycQCKRI2fwzrXYK9xJQm1Zx42" // Güncellendi: Üstteki doğru kullanıcı ID'si

// ===== HX711 PİNLERİ =====
#define SCK_PIN 6
#define P1_DOUT 4
#define P2_DOUT 5

// ===== AYARLAR =====
#define STABILIZING_TIME 2000
#define SEND_INTERVAL_MS 10000UL // Test için 10 saniye yaptım
float CAL1 = 1.0; // Ham veriyi görmek için 1.0 yaptık
float CAL2 = 1.0;

// ===== NESNELER =====
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

HX711_ADC scale1(P1_DOUT, SCK_PIN);
HX711_ADC scale2(P2_DOUT, SCK_PIN);

// ===== PROTOTİPLER =====
void sendData(String id, float weight);
String getTimestamp();

unsigned long lastSendTime = 0;

void setup() {
    Serial.begin(115200);
    delay(2000);
    Serial.println("\n\n=== AKILLI BUZDOLABI BASLIYOR ===");

    // 1. WIFI BAĞLANTISI
    WiFi.mode(WIFI_STA);
    WiFi.setSleep(false);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    Serial.print("WiFi Baglantisi deneniyor");
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\n[BASARILI] WiFi Baglandi!");

    // 2. ZAMAN AYARI
    configTime(0, 0, "pool.ntp.org");

    // 3. FIREBASE YAPILANDIRMASI
    config.api_key = API_KEY;
    auth.user.email = "esp32@auther.com";
    auth.user.password = "esp32pass";
    config.timeout.serverResponse = 15000;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    // 4. SENSÖRLERİ BAŞLAT (OTOMATİK SIFIRLAMA AKTİF)
    Serial.println("\n--- Sensorler Sifirlaniyor (Tare) ---");
    Serial.println("Lutfen platformlarin uzerine dokunmayin...");

    scale1.begin();
    scale1.start(STABILIZING_TIME, true); // TRUE: Açılışta 0 kabul et
    scale1.setCalFactor(CAL1);

    scale2.begin();
    scale2.start(STABILIZING_TIME, true); // TRUE: Açılışta 0 kabul et
    scale2.setCalFactor(CAL2);

    // Bağlantı Kontrolü
    if (scale1.getTareStatus() == true) {
        Serial.println("[OK] Platform 1 Sifirlandi ve Hazir.");
    } else {
        Serial.println("[UYARI] Platform 1 Sifirlanamadi! Kablolari kontrol et.");
    }

    Serial.println("Sistem Hazir.\n");
    lastSendTime = millis();
}

void loop() {
    scale1.update();
    scale2.update();

    if (millis() - lastSendTime >= SEND_INTERVAL_MS) {
        if (WiFi.status() == WL_CONNECTED && Firebase.ready()) {
            float w1 = scale1.getData();
            float w2 = scale2.getData();

            Serial.print("P1: "); Serial.print(w1);
            Serial.print(" | P2: "); Serial.println(w2);

            sendData("platform1", w1);
            sendData("platform2", w2);
        }
        lastSendTime = millis();
    }
}

void sendData(String id, float weight) {
    String json = "{\"fields\":{";
    json += "\"current_weight_kg\":{\"doubleValue\":" + String(weight, 2) + "},";
    json += "\"last_updated\":{\"timestampValue\":\"" + getTimestamp() + "\"}";
    json += "}}";

    String path = "users/" + String(USER_ID) + "/platforms/" + id;

    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), json.c_str(), "current_weight_kg,last_updated")) {
        Serial.println("Firebase Guncellendi: " + id);
    } else {
        Serial.println("Firebase Hatasi: " + fbdo.errorReason());
    }
}

String getTimestamp() {
    struct tm t;
    if (!getLocalTime(&t)) return "2025-01-01T00:00:00Z";
    char buf[25];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &t);
    return String(buf);
}
