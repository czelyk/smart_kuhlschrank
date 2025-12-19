#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "HX711_ADC.h"
#include <time.h>

// ===== WIFI AYARLARI (Basitlestirilmis) =====
#define WIFI_SSID     "Deneme"
#define WIFI_PASSWORD "12345678"

// ===== FIREBASE AYARLARI =====
#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81"
#define USER_ID "8SydQCKRI2fwzrXYK9xJQm1ZxA2"

// ===== HX711 PİNLERİ =====
#define SCK_PIN 6
#define P1_DOUT 4
#define P2_DOUT 5

// ===== AYARLAR =====
#define STABILIZING_TIME 2000
#define SEND_INTERVAL_MS 30000UL  // TEST ICIN: 30 Saniye (Calistigini hemen gor)
float CAL1 = 420.0;
float CAL2 = 420.0;

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
    // Seri portu baslat
    Serial.begin(115200);
    delay(2000);
    Serial.println("\n\n=== AKILLI BUZDOLABI BASLIYOR ===");

    // 1. WIFI BAGLANTISI (En kararli yontem)
    WiFi.persistent(false);
    WiFi.disconnect(true);
    delay(1000);
    WiFi.mode(WIFI_STA);

    Serial.print("WiFi Baglantisi deneniyor: ");
    Serial.println(WIFI_SSID);

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    int counter = 0;
    while (WiFi.status() != WL_CONNECTED && counter < 40) { // 20 saniye deneme
        delay(500);
        Serial.print(".");
        counter++;
    }

    if (WiFi.status() == WL_CONNECTED) {
        Serial.println("\n[BASARILI] WiFi Baglandi! IP: " + WiFi.localIP().toString());
    } else {
        Serial.println("\n[HATA] WiFi Baglanamadi. Ayarlari kontrol et!");
    }

    // 2. ZAMAN AYARI (Firestore timestamp icin zorunlu)
    configTime(0, 0, "pool.ntp.org", "time.google.com");
    Serial.print("Zaman senkronize ediliyor");
    struct tm t;
    int timeRetry = 0;
    while (!getLocalTime(&t) && timeRetry < 10) {
        Serial.print(".");
        delay(1000);
        timeRetry++;
    }
    Serial.println("\nZaman alindi.");

    // 3. FIREBASE AYARLARI
    config.api_key = API_KEY;
    auth.user.email = "esp32@auther.com";
    auth.user.password = "esp32pass";

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    // 4. SENSORLERI BASLAT
    scale1.begin();
    scale1.start(STABILIZING_TIME, true);
    scale1.setCalFactor(CAL1);

    scale2.begin();
    scale2.start(STABILIZING_TIME, true);
    scale2.setCalFactor(CAL2);

    Serial.println("Sistem Hazir. Veri gonderimi bekleniyor...");
    lastSendTime = millis() - SEND_INTERVAL_MS;
}

void loop() {
    // Sensorden surekli veri oku
    scale1.update();
    scale2.update();

    // Zaman araligi kontrolu
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

void sendData(String id, float weight) {
    // Firestore JSON Formati (current_weight_kg ve last_updated alanlari)
    String json = "{\"fields\":{";
    json += "\"current_weight_kg\":{\"doubleValue\":" + String(weight, 2) + "},";
    json += "\"last_updated\":{\"timestampValue\":\"" + getTimestamp() + "\"}";
    json += "}}";

    // Firestore klasor hiyerarsisi
    String path = "users/" + String(USER_ID) + "/platforms/" + id;

    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), json.c_str(), "current_weight_kg,last_updated")) {
        Serial.println("TAMAM: " + id + " -> " + String(weight, 2) + " kg");
    } else {
        Serial.println("HATA (" + id + "): " + fbdo.errorReason());
    }
}

String getTimestamp() {
    struct tm t;
    if (!getLocalTime(&t)) return "2025-01-01T00:00:00Z"; // Hata durumunda yedek
    char buf[25];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &t);
    return String(buf);
}