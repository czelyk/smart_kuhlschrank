/*
  Smart Kühlschrank - ESP32 Hauptcode
  Version: 2 Regale (Platform 1 & 2), Stündliches Update (Deep Sleep)
*/

// --- Benötigte Bibliotheken ---
#include <WiFi.h>
#include <Firebase_ESP_Client.h> // Firebase Bibliothek
#include "HX711_ADC.h"       // Gewichtssensor-Bibliothek

// --- SCHRITT 1: AUSFÜLLEN (WLAN-Zugangsdaten) ---
#define WIFI_SSID "Izvini?"
#define WIFI_PASSWORD "ahmethasan"

// --- SCHRITT 2: API SCHLÜSSEL & PROJEKT ID ---
#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81"

// --- SCHRITT 3: PIN-Zuweisung (Anpassen) ---
const int PLATFORM1_HX711_DOUT_PIN = 6; 
const int PLATFORM1_HX711_SCK_PIN  = 7; 

const int PLATFORM2_HX711_DOUT_PIN = 4; 
const int PLATFORM2_HX711_SCK_PIN  = 5; 

// --- SCHRITT 4: AUSFÜLLEN (Kalibrierung) ---
float PLATFORM1_CALIBRATION_FACTOR = 420.0;
float PLATFORM2_CALIBRATION_FACTOR = 420.0;

// --- Weitere Einstellungen ---
const int STABILIZING_TIME = 2000; 
#define DEEP_SLEEP_SECONDS 3600

// --- Globale Firebase-Objekte ---
FirebaseData fbdo_platform1;   
FirebaseData fbdo_platform2;   
FirebaseAuth auth;    
FirebaseConfig config; 

// --- Sensor-Objekte ---
HX711_ADC scale_platform1(PLATFORM1_HX711_DOUT_PIN, PLATFORM1_HX711_SCK_PIN);
HX711_ADC scale_platform2(PLATFORM2_HX711_DOUT_PIN, PLATFORM2_HX711_SCK_PIN);

// --- Funktionsdeklarationen ---
void sendDataToFirebase(String platformId, float weight); 
String getFirebaseTimestamp();
void tokenStatusCallback(TokenInfo info); 

// ====================================================
// SETUP
// ====================================================
void setup() {
  Serial.begin(115200);
  Serial.println("\nESP32 aufgewacht! (Platform 1&2 Version)");

  // --- WLAN-Verbindung ---
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Verbinde mit WLAN");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Verbunden! IP-Adresse: ");
  Serial.println(WiFi.localIP());

  // --- Firebase-Verbindung ---
  Serial.println("Verbinde mit Firebase...");
  config.api_key = API_KEY;
  auth.user.email = "esp32@auther.com"; 
  auth.user.password = "esp32pass";      
  config.token_status_callback = tokenStatusCallback; 
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  // --- ZEIT-SYNCHRONISIERUNG ---
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.println("Warte auf NTP-Zeitsynchronisierung...");
  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println("\nZeitsynchronisierung erfolgreich!");

  // --- Sensor-Initialisierung ---
  // Platform 1
  Serial.println("Platform 1-Sensor wird initialisiert...");
  scale_platform1.begin();
  scale_platform1.start(STABILIZING_TIME, true); 
  if (scale_platform1.getTareTimeoutFlag()) {
    Serial.println("Platform 1-Sensor Tara-Timeout! (0.00 wird gesendet)");
  } else {
    Serial.println("Platform 1-Sensor tariert.");
    scale_platform1.setCalFactor(PLATFORM1_CALIBRATION_FACTOR); 
  }

  // Platform 2
  Serial.println("Platform 2-Sensor wird initialisiert...");
  scale_platform2.begin();
  scale_platform2.start(STABILIZING_TIME, true); 
  if (scale_platform2.getTareTimeoutFlag()) {
    Serial.println("Platform 2-Sensor Tara-Timeout! (0.00 wird gesendet)");
  } else {
    Serial.println("Platform 2-Sensor tariert.");
    scale_platform2.setCalFactor(PLATFORM2_CALIBRATION_FACTOR); 
  }

  // --- Hauptoperation ---
  if (Firebase.ready()) {
    float weight_platform1 = scale_platform1.getData();
    Serial.print("Platform 1-Gewicht: ");
    Serial.print(weight_platform1, 2);
    Serial.println(" kg");
    sendDataToFirebase("platform1", weight_platform1);

    float weight_platform2 = scale_platform2.getData();
    Serial.print("Platform 2-Gewicht: ");
    Serial.print(weight_platform2, 2);
    Serial.println(" kg");
    sendDataToFirebase("platform2", weight_platform2);
    
  } else {
    Serial.println("Fehler: Firebase nicht bereit. Senden übersprungen.");
  }

  // --- Schlafmodus ---
  Serial.println("Vorgang abgeschlossen. Gehe für 1 Stunde in den Tiefschlaf...");
  ESP.deepSleep(DEEP_SLEEP_SECONDS * 1000000);
}

// ====================================================
// LOOP (Wird wegen Deep Sleep NIEMALS ausgeführt)
// ====================================================
void loop() {}

// ====================================================
// Daten-Sende-Funktion
// ====================================================
void sendDataToFirebase(String platformId, float weight) {
  Serial.println("---------------------------------");
  Serial.print("Sende Daten für: ");
  Serial.println(platformId);

  String content = R"({"fields":{"current_weight_kg":{"doubleValue":)";
  content += String(weight, 2);
  content += R"(},"last_updated":{"timestampValue":")";
  content += getFirebaseTimestamp();
  content += R"("}}})";

  String document_path = "platforms/" + platformId;
  FirebaseData* fbdo_ptr = (platformId == "platform2") ? &fbdo_platform2 : &fbdo_platform1;

  if (Firebase.Firestore.patchDocument(fbdo_ptr, FIREBASE_PROJECT_ID, "", document_path.c_str(), content.c_str(), "current_weight_kg,last_updated")) {
    Serial.print("ERFOLG: '");
    Serial.print(document_path);
    Serial.println("' Dokument aktualisiert.");
  } else {
    Serial.print("FEHLER: Konnte '");
    Serial.print(document_path);
    Serial.println("' Dokument NICHT aktualisieren!");
    Serial.println(fbdo_ptr->errorReason());
  }
  Serial.println("---------------------------------");
}

// ====================================================
// Hilfsfunktionen
// ====================================================
String getFirebaseTimestamp() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Zeit konnte nicht abgerufen werden!");
    return "";
  }
  char buf[sizeof "2011-10-08T07:07:09Z"];
  strftime(buf, sizeof buf, "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}

void tokenStatusCallback(TokenInfo info) {
  if (info.status == token_status_ready) {
    Serial.println("Firebase Token erhalten.");
  } else {
    Serial.print("Firebase Token Fehler: ");
    Serial.println(info.error.message.c_str());
  }
}
