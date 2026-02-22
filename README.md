🧊 Smarty: Intelligentes Kühlschranksystem (IoT & Mobile)

Dieses Projekt ist ein umfassendes IoT-System, das das Gewicht der Produkte im Kühlschrank in Echtzeit erfasst, über Bluetooth kalibriert werden kann und die Daten über ein Admin-Panel mit Firebase Firestore analysiert.

📂 Projektstruktur und Dateipfade
1. ESP32 (IoT-Gerät) – Code

Speicherort: /Arduino/smart_kuehlschrank_esp32.ino/esp32.ino

Aufgabe:

Auslesen der Gewichtssensoren (HX711)

Empfang von Konfigurationsdaten über Bluetooth

Übertragung der Daten an Firebase

Segmentierung:
Der Code ist gemäß den Anforderungen des Dozenten in drei Hauptbereiche unterteilt (Ahmet, Tobias, Lucas).

2. Mobile Anwendung (Flutter)

Speicherort: /lib

Benutzeranwendung:
Die Haupt-App, in der Benutzer den Kühlschrank einrichten, das Gerät über Bluetooth koppeln und die Kalibrierung durchführen.

Admin-Panel:
Ein Verwaltungsbereich zur Marktanalyse, Nutzerverfolgung und Überwachung KI-basierter Verbrauchsmuster.

🛠️ Technische Spezifikationen
🦾 Verwendung von Inline-Assembly

Der ESP32-Code enthält drei verschiedene Inline-Assembly-Sequenzen, passend zur Xtensa-Prozessorarchitektur:

WiFi-Zähler (addi)
Zählt WLAN-Verbindungsversuche auf Hardware-Ebene. (Ahmet)

Synchronisation (nop)
Stoppt den Prozessor im Mikrosekundenbereich vor der Bluetooth-Datenverarbeitung. (Tobias)

Arithmetische Operation (add)
Führt schnelle Additionen bei der Datenverpackung aus. (Lucas)

🔵 Bluetooth (BLE)-Verwaltung

Während der Einrichtungsphase arbeitet das Gerät vollständig dynamisch:

UID-Festlegung:
Die Benutzer-ID, an die das Gerät Daten sendet, wird über den Befehl
UID:user_id aus der App gesetzt.

WiFi-Konfiguration:
Netzwerkdaten werden über den Befehl
WIFI:ssid;password übermittelt.

Präzisionskalibrierung:
Die Sensoren werden mit einem 800g (0,8kg) Referenzgewicht über den Befehl
CAL:P1:800 kalibriert.

📊 Daten & Analyse

Firebase Firestore:
Die Daten werden unter users/{userId}/platforms/ gespeichert.

Gatt 133 Lösung:
Zur Vermeidung von Bluetooth-Instabilitäten (häufig bei Android-Geräten) wird der Modus
PROPERTY_WRITE_NR (No Response) verwendet.

🚀 Einrichtung und Ausführung
Geräte-Firmware

Den Code aus dem Ordner /Arduino mit der Arduino IDE auf den ESP32 hochladen.

Mobile Anwendung

Abhängigkeiten installieren mit:
flutter pub get

Anwendung starten mit:
flutter run

Geräteverbindung

Den ESP32 in der App unter „Account“ → „Device Setup“ suchen und koppeln.

Die Waagen im Bereich „Sensor Calibration“ mit einem 800g-Gewicht kalibrieren.

👥 Entwickler und Verantwortlichkeiten

Ahmet: WiFi-Architektur, globale Einstellungen, Assembly (Zähler)

Tobias: Bluetooth (BLE)-Services, Kalibrierungslogik, Assembly (Delay)

Lucas: Firebase-Datenübertragung, Sensorauslesung, Assembly (Addition)
