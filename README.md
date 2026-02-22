# 🧊 Smarty: Smart Fridge System (IoT & Mobile)

This project is a comprehensive IoT system that tracks the weight of products inside a refrigerator in real-time, can be calibrated via Bluetooth, and analyzes data through an Admin Panel over Firebase Firestore.

---

## 📂 Project Structure and File Locations

### 1. ESP32 (IoT Device) Codes
**Location:** `/Arduino/smart_kuehlschrank_esp32.ino/esp32.ino`
*   **Task:** Reading data from weight sensors (HX711), receiving configuration via Bluetooth, and sending data to Firebase.
*   **Segmentation:** The code is divided into 3 main sections (Ahmet, Tobias, Lucas) as per the instructor's requirement.

### 2. Mobile Application (Flutter)
**Location:** `/lib`
*   **User Application:** The main application where users set up the fridge, pair via Bluetooth, and perform calibration.
*   **Admin Panel:** A panel where market analysis, user tracking, and AI-based consumption patterns are monitored.

---

## 🛠️ Technical Specifications

### 🦾 Inline Assembly Usage
The ESP32 code utilizes 3 different assembly code snippets suitable for the processor architecture (Xtensa):
1.  **WiFi Counter (`addi`):** Counts WiFi connection attempts at the hardware level. (Ahmet)
2.  **Synchronization (`nop`):** Pauses the processor at a micro-second level before Bluetooth data processing. (Tobias)
3.  **Arithmetic Operation (`add`):** Performs fast addition during data packaging. (Lucas)

### 🔵 Bluetooth (BLE) Management
The device is fully dynamic during the setup phase:
*   **UID Setting:** The user ID that the device will send data to is determined via the `UID:user_id` command from the app.
*   **WiFi Setting:** The network credentials are set via the `WIFI:ssid;password` command.
*   **Precision Calibration:** Sensors are calibrated using an 800g (0.8kg) reference weight via the `CAL:P1:800` command.

### 📊 Data & Analytics
*   **Firebase Firestore:** Data is stored under `users/{userId}/platforms/`.
*   **Gatt 133 Solution:** The `PROPERTY_WRITE_NR` (No Response) mode is used to prevent Bluetooth instability issues common on Android devices.

---

## 🚀 Setup and Running

1.  **Device Firmware:** Upload the code in the `/Arduino` folder to the ESP32 using the Arduino IDE.
2.  **Mobile Application:**
    *   Install dependencies with the `flutter pub get` command.
    *   Start the application with `flutter run`.
3.  **Device Connection:**
    *   Find and pair the ESP32 from the "Account" -> "Device Setup" section in the app.
    *   Calibrate the scales with an 800-gram weight from the "Sensor Calibration" tab.

---

## 👥 Developers and Responsibilities
*   **Ahmet:** WiFi Architecture, Global Settings, Assembly (Counter).
*   **Tobias:** Bluetooth (BLE) Services, Calibration Logic, Assembly (Delay).
*   **Lucas:** Firebase Data Transmission, Sensor Reading, Assembly (Addition).
