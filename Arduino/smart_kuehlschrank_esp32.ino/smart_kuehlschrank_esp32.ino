/*
  Smart Kühlschrank - ESP32 Hauptcode
  Version: 2 Regale (Pülleken & Bitburger), Stündliches Update (Deep Sleep)
  
  *** FIX: Zeitstempel-Format (strftime) korrigiert für 'last_updated' ***
  Dieser Code verwendet die "HX711_ADC by Olav Kallhovd" Bibliothek.
*/

// --- Benötigte Bibliotheken ---
#include <WiFi.h>
#include <Firebase_ESP_Client.h> // Firebase Bibliothek
#include "HX711_ADC.h"       // Gewichtssensor-Bibliothek (Header-Name korrigiert: _ADC)

// --- SCHRITT 1: AUSFÜLLEN (WLAN-Zugangsdaten) ---
#define WIFI_SSID "Izvini?"
#define WIFI_PASSWORD "ahmethasan"

// --- SCHRITT 2: API SCHLÜSSEL (Aktualisiert) ---
#define API_KEY "AIzaSyAMHeRwya8gQiK7-5u1557chofAv-gZTWk"
#define FIREBASE_PROJECT_ID "smart-kuehlschrank81" // Diese ID ist korrekt

// --- SCHRITT 3: ESP32-C3 GÜVENLİ PİNLER (Anpassen) ---
// ESP32-C3'te 25, 26, 27 pinleri yoktur! Bu pinler C3 için güvenlidir:
// Örnek olarak GPIO 4, 5, 6, 7 kullanılmıştır.
const int PULLEKEN_HX711_DOUT_PIN = 4; // BEISPIEL: GPIO 4 (Anpassen)
const int PULLEKEN_HX711_SCK_PIN  = 5; // BEISPIEL: GPIO 5 (Anpassen)

const int BITBURGER_HX711_DOUT_PIN = 6; // BEISPIEL: GPIO 6 (Anpassen)
const int BITBURGER_HX711_SCK_PIN  = 7; // BEISPIEL: GPIO 7 (Anpassen)

// --- SCHRITT 4: AUSFÜLLEN (Kalibrierung) ---
float PULLEKEN_CALIBRATION_FACTOR = 420.0; // Beispielwert
float BITBURGER_CALIBRATION_FACTOR = 420.0; // Beispielwert

// --- Weitere Einstellungen ---
const int STABILIZING_TIME = 2000; // Zeit (ms) zur Stabilisierung des Sensors
#define DEEP_SLEEP_SECONDS 3600      // 1 Stunde = 3600 Sekunden

// --- Globale Firebase-Objekte ---
FirebaseData fbdo_pulleken;    // Separates Objekt für Pülleken
FirebaseData fbdo_bitburger;   // Separates Objekt für Bitburger
FirebaseAuth auth;    
FirebaseConfig config; 

// --- Sensor-Objekte (KORRIGIERT) ---
HX711_ADC scale_pulleken(PULLEKEN_HX711_DOUT_PIN, PULLEKEN_HX711_SCK_PIN);
HX711_ADC scale_bitburger(BITBURGER_HX711_DOUT_PIN, BITBURGER_HX711_SCK_PIN);

// --- Funktionsdeklarationen (Erforderlich) ---
void sendDataToFirebase(String platformId, float weight); // Angepasst für 2 Sensoren
String getFirebaseTimestamp();
void tokenStatusCallback(TokenInfo info); // Für Firebase Callback

// ====================================================
// SETUP: Diese Funktion läuft einmal ab, wenn der ESP32 aufwacht
// ====================================================
void setup() {
  Serial.begin(115200);
  Serial.println("\nESP32 aufgewacht! (2-Sensor / C3-FIX / Timestamp-FIX Version)");

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
  config.token_status_callback = tokenStatusCallback; // Callback zuweisen
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  // --- ZEIT-SYNCHRONISIERUNG (KORRIGIERT) ---
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  
  Serial.println("Warte auf NTP-Zeitsynchronisierung...");
  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(1000); // 1 saniye bekle ve tekrar dene
  }
  Serial.println("\nZeitsynchronisierung erfolgreich!");
  // --- KORREKTUR ENDE ---


  // --- Sensor-Initialisierung ---
  // (Not: 'pulleken_ready' ve 'bitburger_ready' değişkenleri kaldırıldı,
  // çünkü sensör bağlı olmasa bile 0.00 göndermek istiyoruz)

  // Pülleken Sensor
  Serial.println("Pülleken-Sensor wird initialisiert (Pin D4, S5)...");
  scale_pulleken.begin();
  scale_pulleken.start(STABILIZING_TIME, true); // Sensor starten und tarieren (nullen)
  if (scale_pulleken.getTareTimeoutFlag()) {
    Serial.println("Pülleken-Sensor Tara-Timeout! (0.00 wird gesendet)");
  } else {
    Serial.println("Pülleken-Sensor tariert (auf Null gesetzt).");
    scale_pulleken.setCalFactor(PULLEKEN_CALIBRATION_FACTOR); // Kalibrierungsfaktor setzen
  }

  // Bitburger Sensor
  Serial.println("Bitburger-Sensor wird initialisiert (Pin D6, S7)...");
  scale_bitburger.begin();
  scale_bitburger.start(STABILIZING_TIME, true); // Sensor starten und tarieren (nullen)
  if (scale_bitburger.getTareTimeoutFlag()) {
    Serial.println("Bitburger-Sensor Tara-Timeout! (0.00 wird gesendet)");
  } else {
    Serial.println("Bitburger-Sensor tariert (auf Null gesetzt).");
    scale_bitburger.setCalFactor(BITBURGER_CALIBRATION_FACTOR); // Kalibrierungsfaktor setzen
  }

  // --- Hauptoperation ---
  // Daten nur senden, wenn Firebase bereit ist
  if (Firebase.ready()) {
    
    // (FIX) Sensör bağlı olmasa bile 0.00 gönder
    float weight_pulleken = scale_pulleken.getData();
    Serial.print("Pülleken-Gewicht: ");
    Serial.print(weight_pulleken, 2);
    Serial.println(" kg");
    sendDataToFirebase("pulleken", weight_pulleken); // Sendet Pülleken-Daten

    // (FIX) Sensör bağlı olmasa bile 0.00 gönder
    float weight_bitburger = scale_bitburger.getData();
    Serial.print("Bitburger-Gewicht: ");
    Serial.print(weight_bitburger, 2);
    Serial.println(" kg");
    sendDataToFirebase("bitburger", weight_bitburger); // Sendet Bitburger-Daten
    
  } else {
    Serial.println("Fehler: Firebase nicht bereit. Senden übersprungen.");
  }

  // --- Schlafmodus ---
  Serial.println("Vorgang abgeschlossen. Gehe für 1 Stunde in den Tiefschlaf...");
  ESP.deepSleep(DEEP_SLEEP_SECONDS * 1000000); // Sekunden in Mikrosekunden umrechnen
}

// ====================================================
// LOOP: (Wird wegen Deep Sleep NIEMALS ausgeführt)
// ====================================================
void loop() {
  // Bleibt leer, da wir Deep Sleep verwenden.
}

// ====================================================
// Daten-Sende-Funktion (Angepasst)
// =EG==================================================
void sendDataToFirebase(String platformId, float weight) {
  Serial.println("---------------------------------");
  Serial.print("Sende Daten für: ");
  Serial.println(platformId);

  // 1. Firestore için JSON içeriğini hazırla
  String content = R"({"fields":{"current_weight_kg":{"doubleValue":)";
  content += String(weight, 2); // 'weight' değişkenini kullan
  content += R"(},"last_updated":{"timestampValue":")";
  content += getFirebaseTimestamp(); // Aktuellen Zeitstempel hinzufügen
  content += R"("}}})";

  // 2. 'platforms/[platformId]' Dokümanını güncelle (patch)
  String document_path = "platforms/" + platformId;
  FirebaseData* fbdo_ptr = (platformId == "pulleken") ? &fbdo_pulleken : &fbdo_bitburger;

  if (Firebase.Firestore.patchDocument(fbdo_ptr, FIREBASE_PROJECT_ID, "", document_path.c_str(), content.c_str(), "current_weight_kg,last_updated")) {
    Serial.print("ERFOLGREICH: '");
    Serial.print(document_path);
    Serial.println("' Dokument aktualisiert.");
    Serial.println(fbdo_ptr->payload());
  } else {
    Serial.print("FEHLER: Konnte '");
    Serial.print(document_path);
    Serial.println("' Dokument NICHT aktualisieren!");
    Serial.println(fbdo_ptr->errorReason());
  }
  Serial.println("---------------------------------");
}

// ====================================================
// Hilfsfunktionen (Unverändert)
// ====================================================

// Gibt den aktuellen UTC-Zeitstempel für Firebase zurück
String getFirebaseTimestamp() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Zeit konnte nicht abgerufen werden (Sollte nicht passieren!)");
    return "";
  }
  
  // *** HATA DÜZELTMESİ (FIX) BURADA ***
  // "%Y-%m-%dTH:%M:%SZ" olan hatalı format "%Y-%m-%dT%H:%M:%SZ" olarak düzeltildi.
  char buf[sizeof "2011-10-08T07:07:09Z"];
  strftime(buf, sizeof buf, "%Y-%m-%dT%H:%M:%SZ", &timeinfo); // 'T' harfi %d'den ayrıldı.
  // *** DÜZELTME SONU ***

  return String(buf);
}

// Erforderliche Callback-Funktion für die Firebase-Bibliothek
void tokenStatusCallback(TokenInfo info) {
  // Token-Status an den Seriellen Monitor senden
  if (info.status == token_status_ready) {
    Serial.println("Firebase Token erhalten.");
  } else {
    Serial.print("Firebase Token Fehler: ");
    Serial.println(info.error.message.c_str());
  }
}