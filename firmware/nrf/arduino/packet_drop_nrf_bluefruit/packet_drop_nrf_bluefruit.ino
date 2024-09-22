#include <bluefruit.h>

#define FAST
#define CONN_PARAM 6
#define DATA_NUM 240

BLEService uploadService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, DATA_NUM);
BLECharacteristic delayCharacteristic("19B10002-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, sizeof(uint32_t));
BLECharacteristic burstTimeCharacteristic("19B10003-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, sizeof(uint32_t));

const int packetCount = 100;
const unsigned long sendInterval = 20000; // 10 seconds in milliseconds
unsigned long lastSendTime = 0;
uint32_t packetNumber = 0;
uint32_t packetDelay = 10; // Default delay between packets (in milliseconds)
bool connectedFlag = false;

void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);

  Serial.println("Bluefruit52 Random Data Sender");
  Serial.println("-------------------------------\n");

  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
  Bluefruit.configUuid128Count(15);
  Bluefruit.begin();
  Bluefruit.setTxPower(0);
  Bluefruit.setName("Random Data Sender");
  Bluefruit.setConnLedInterval(50);
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  setupServices();
  startAdv();

  Serial.println("Ready to connect");
}

void setupServices() {
  uploadService.begin();

  dataCharacteristic.setProperties(CHR_PROPS_NOTIFY);
  // dataCharacteristic.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  dataCharacteristic.setFixedLen(DATA_NUM);
  dataCharacteristic.begin();


}

void startAdv() {
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addService(uploadService);
  Bluefruit.ScanResponse.addName();
  
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setIntervalMS(20, 153);     // fast mode 20mS, slow mode 153mS
  Bluefruit.Advertising.setFastTimeout(30);         // fast mode 30 sec
  Bluefruit.Advertising.start(0);    
}

void loop() {
  if (Bluefruit.connected() && connectedFlag) {
    unsigned long currentTime = millis();
    if (currentTime - lastSendTime >= sendInterval) {
      sendRandomData();
      lastSendTime = currentTime;
    }
  }
}

void sendRandomData() {
  packetNumber = 0;
  unsigned long startTime = millis();
  
  for (int i = 0; i < packetCount; i++) {
    uint8_t packet[DATA_NUM];
    packet[0] = 0;//(packetNumber >> 24) & 0xFF;
    packet[1] = 0;(packetNumber >> 16) & 0xFF;
    packet[2] = 0;(packetNumber >> 8) & 0xFF;
    packet[3] = packetNumber;//packetNumber & 0xFF;
    
    for (int j = 4; j < DATA_NUM; j++) {
      packet[j] = 0;//random(256);
    }
    
    dataCharacteristic.notify(packet, DATA_NUM);
    // delay(packetDelay);
    
    // Serial.print("Sent packet ");
    // Serial.println(packetNumber);
    packetNumber++;
  }
  
  unsigned long endTime = millis();
  uint32_t burstTime = endTime - startTime;
  burstTimeCharacteristic.notify32(burstTime);
  
  Serial.print("Finished sending 100 packets. Total time: ");
  Serial.print(burstTime);
  Serial.println(" ms");
  delay(1000);
}

void connect_callback(uint16_t conn_handle) {
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  connection->requestPHY();
  delay(1000);
  connection->requestDataLengthUpdate();
  connection->requestMtuExchange(DATA_NUM + 3);
  connection->requestConnectionParameter(CONN_PARAM);
  delay(1000);

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  Serial.print("Connected to ");
  Serial.println(central_name);
  Serial.print("PHY: "); Serial.println(connection->getPHY());
  Serial.print("Data Length: "); Serial.println(connection->getDataLength());
  Serial.print("MTU: "); Serial.println(connection->getMtu());
  Serial.print("Connection Interval: "); Serial.println(connection->getConnectionInterval());

  connectedFlag = true;
}

void disconnect_callback(uint16_t conn_handle, uint8_t reason) {
  (void) conn_handle;
  (void) reason;

  Serial.print("Disconnected, reason = 0x");
  Serial.println(reason, HEX);
  connectedFlag = false;
}