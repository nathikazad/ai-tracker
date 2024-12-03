#include <Adafruit_TinyUSB.h>
#include <bluefruit.h>
void setup() {


  // Set USB descriptors
  TinyUSBDevice.setManufacturerDescriptor("Aspire");
  TinyUSBDevice.setProductDescriptor("Aspire");

  // Initialize USB Serial
  Serial.begin(115200);
}

void loop() {
  Serial.print("Hello! @ ");
  Serial.println(millis());
  Serial.flush();
  delay(1000);
}