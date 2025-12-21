#include <Arduino.h>
#include "HX711_ADC.h"

// ===== HX711 PİN TANIMLARI =====
#define SCK_PIN 6
#define P1_DOUT 4

// ===== LED PINLERİ =====
#define LED1_PIN 18

// ===== AYARLAR =====
#define STABILIZING_TIME 5000    // Daha uzun stabilize süresi
#define AVERAGE_SAMPLES 5        // Ortalama için son 5 ölçümü kullan

// ===== NESNELER =====
HX711_ADC scale1(P1_DOUT, SCK_PIN);
float rawBuffer[AVERAGE_SAMPLES];
int rawIndex = 0;

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("\n\n=== PLATFORM1 HAM VERI TESTI BASLIYOR ===");

  // LED pinini OUTPUT olarak ayarla ve aç
  pinMode(LED1_PIN, OUTPUT);
  digitalWrite(LED1_PIN, HIGH);

  // Platform1 sensörünü başlat
  scale1.begin();
  scale1.start(STABILIZING_TIME, true);

  // Tare (sıfırlama) yap
  scale1.tareNoDelay();

  // Bufferı sıfırla
  for(int i=0; i<AVERAGE_SAMPLES; i++) rawBuffer[i] = 0;

  Serial.println("Sistem hazır. Platform1 ham verisi gösteriliyor...");
}

void loop() {
  scale1.update();

  // Ham veriyi oku
  float raw1 = scale1.getData();

  // Buffera ekle
  rawBuffer[rawIndex] = raw1;
  rawIndex = (rawIndex + 1) % AVERAGE_SAMPLES;

  // Ortalama al
  float sum = 0;
  for(int i=0; i<AVERAGE_SAMPLES; i++) sum += rawBuffer[i];
  float averageRaw = sum / AVERAGE_SAMPLES;

  // Seri monitöre yazdır
  Serial.println("\n>> Ham veri (ortalama):");
  Serial.println("Platform1 raw: " + String(averageRaw, 2));

  delay(500); // Çok hızlı yazmaması için kısa bekleme
}
