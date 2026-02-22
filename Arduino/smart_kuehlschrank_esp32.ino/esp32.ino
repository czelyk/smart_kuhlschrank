/************************************************************
 * PART 1 – AHMET (WiFi & Global)
 ************************************************************/
#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "HX711.h"
#include <time.h>
#include <Preferences.h>

#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81"
#define SCK_PIN 6
#define P1_DOUT 4
#define P2_DOUT 5
#define SEND_INTERVAL_MS 30000UL

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
Preferences preferences;
String userId = "";
unsigned long lastSendTime = 0;
bool deviceConnected = false;

void connectWiFiWithAssembly(String ssid, String pass) {
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid.c_str(), pass.c_str());
    Serial.print("WiFi Connecting: " + ssid);
    int counter = 0;
    while (WiFi.status() != WL_CONNECTED && counter < 20) {
        delay(500); Serial.print(".");
        asm volatile ("addi %0, %0, 1" : "+r"(counter)); 
    }
    if (WiFi.status() == WL_CONNECTED) Serial.println("\n[OK] Connected!");
}

/************************************************************
 * PART 2 – TOBIAS (BLE & Calibration)
 ************************************************************/
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define BLE_SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define BLE_CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

HX711 scale1;
HX711 scale2;
float CAL1 = 420.0, CAL2 = 420.0;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println(">>> Bluetooth: Cihaz Bağlandı");
    };
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println(">>> Bluetooth: Cihaz Ayrıldı");
      pServer->getAdvertising()->start(); // Tekrar yayına başla
    }
};

class MyCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        String data = "";
        for (char c : value) data += c;
        data.trim();

        asm volatile("nop; nop;"); 

        preferences.begin("smart-fridge", false);
        if (data.startsWith("UID:")) {
            preferences.putString("user_id", data.substring(4));
            preferences.end();
            Serial.println("UID saved. Restarting...");
            delay(500); ESP.restart();
        } 
        else if (data.startsWith("WIFI:")) {
            String creds = data.substring(5);
            int sep = creds.indexOf(';');
            if (sep != -1) {
                preferences.putString("wifi_ssid", creds.substring(0, sep));
                preferences.putString("wifi_pass", creds.substring(sep + 1));
                preferences.end();
                Serial.println("WiFi saved. Restarting...");
                delay(500); ESP.restart();
            }
        }
        else if (data == "CAL:ZERO") {
            scale1.tare(); scale2.tare();
            Serial.println("Tare done.");
        }
        else if (data == "CAL:P1:800") {
            float newCal = (float)scale1.get_value(10) / 0.8f;
            scale1.set_scale(newCal);
            preferences.putFloat("cal1", newCal);
            Serial.println("P1 Calibrated.");
        }
        else if (data == "CAL:P2:800") {
            float newCal = (float)scale2.get_value(10) / 0.8f;
            scale2.set_scale(newCal);
            preferences.putFloat("cal2", newCal);
            Serial.println("P2 Calibrated.");
        }
        preferences.end();
    }
};

void setupBLE() {
    BLEDevice::init("Smart Fridge ESP32");
    BLEServer *pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());
    BLEService *pService = pServer->createService(BLE_SERVICE_UUID);
    
    // PROPERTY_WRITE_NR (No Response) Android için daha stabildir
    BLECharacteristic *pCh = pService->createCharacteristic(
        BLE_CHARACTERISTIC_UUID_RX,
        BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
    );
    pCh->setCallbacks(new MyCallbacks());
    pService->start();
    pServer->getAdvertising()->start();
}

/************************************************************
 * PART 3 – LUCAS (Transmission)
 ************************************************************/
int assemblyAdd(int a, int b) {
    int res;
    asm volatile ("add %0, %1, %2" : "=r"(res) : "r"(a), "r"(b)); 
    return res;
}

String getTimestamp() {
    struct tm ti;
    if (!getLocalTime(&ti)) return "2025-01-01T00:00:00Z";
    char buf[32];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &ti);
    return String(buf);
}

void sendData(String id, float weight) {
    if (userId == "" || WiFi.status() != WL_CONNECTED) return;
    String path = "users/" + userId + "/platforms/" + id;
    String json = "{\"fields\":{\"current_weight_kg\":{\"doubleValue\":" + String(weight, 2) + "},\"last_updated\":{\"timestampValue\":\"" + getTimestamp() + "\"}}}";
    Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), json.c_str(), "current_weight_kg,last_updated");
}

void setup() {
    Serial.begin(115200);
    preferences.begin("smart-fridge", false);
    userId = preferences.getString("user_id", "");
    String ssid = preferences.getString("wifi_ssid", "Deneme");
    String pass = preferences.getString("wifi_pass", "12345678");
    CAL1 = preferences.getFloat("cal1", 420.0);
    CAL2 = preferences.getFloat("cal2", 420.0);
    preferences.end();

    setupBLE();
    scale1.begin(P1_DOUT, SCK_PIN); scale2.begin(P2_DOUT, SCK_PIN);
    scale1.set_scale(CAL1);         scale2.set_scale(CAL2);
    scale1.tare();                  scale2.tare();

    if (ssid != "") connectWiFiWithAssembly(ssid, pass);
    if (WiFi.status() == WL_CONNECTED) {
        configTime(0, 0, "pool.ntp.org");
        config.api_key = API_KEY;
        auth.user.email = "esp32@auther.com"; auth.user.password = "esp32pass";
        Firebase.begin(&config, &auth);
    }
}

void loop() {
    if (millis() - lastSendTime > SEND_INTERVAL_MS) {
        if (WiFi.status() == WL_CONNECTED && userId != "") {
            float w1 = scale1.get_units(10);
            float w2 = scale2.get_units(10);
            sendData("platform1", (w1 < 0) ? 0 : w1);
            sendData("platform2", (w2 < 0) ? 0 : w2);
        }
        lastSendTime = millis();
    }
}
