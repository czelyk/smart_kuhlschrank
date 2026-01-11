#include "HX711.h"

static const int HX_DOUT = 4;
static const int HX_SCK  = 6;

HX711 scale;

long raw0 = 0;
float k = 1.0f;

long readAvg(int n=20){
  long sum = 0;
  for(int i=0;i<n;i++){
    sum += scale.read();
    delay(5);
  }
  return sum / n;
}
void setup() {
  Serial.begin(115200);
  delay(500);

  scale.begin(HX_DOUT, HX_SCK);
  Serial.print("Plattengewicht:  ");
  raw0 = readAvg(30);
  Serial.println(raw0);
  delay(2000);
  Serial.print("Referenzgewicht platzieren...");
  delay(5000);
  long dRef = readAvg(30);
  const float gRef = 800.0f;       // Referenzgewicht individuell einstellen zum Umrechnen
  k = gRef / (dRef - raw0);
}

void loop() {
  long raw = readAvg(30);   // 24-bit Rohwert
  float m = (raw - raw0) * k;
  Serial.print("Gewicht: ");
  Serial.println(m,1);
  delay(2000);
}
