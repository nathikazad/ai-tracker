#include <bluefruit.h>

// BLE Service UUIDs
#define SERIAL_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_RX_UUID      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_TX_UUID      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

#define CONN_PARAM  6

#define FRAME_WIDTH 160
#define FRAME_HEIGHT 120
#define FRAME_SIZE (FRAME_WIDTH * FRAME_HEIGHT)
#define PACKET_SIZE 244
#define PACKET_HEADER_SIZE 2
#define PACKET_DATA_SIZE (PACKET_SIZE - PACKET_HEADER_SIZE)
#define NUM_PACKETS ((FRAME_SIZE + PACKET_DATA_SIZE - 1) / PACKET_DATA_SIZE)

// BLE Service and Characteristics
BLEService serialService(SERIAL_SERVICE_UUID);
BLECharacteristic serialRxCharacteristic(SERIAL_RX_UUID, BLEWrite | BLEWriteWithoutResponse, PACKET_SIZE);
BLECharacteristic serialTxCharacteristic(SERIAL_TX_UUID, BLENotify, PACKET_SIZE);

// Frame buffer and state
uint8_t buffer[FRAME_SIZE];
uint16_t bufferIndex = 0;
bool startFound = false;
uint8_t lastByte = 0;  
bool connectedFlag = false;
int lastPacketSentTime = millis();

void connect_callback(uint16_t conn_handle) {
    BLEConnection* connection = Bluefruit.Connection(conn_handle);
    connection->requestPHY();
    delay(1000);
    connection->requestDataLengthUpdate();
    connection->requestMtuExchange(PACKET_SIZE + 3);
    connection->requestConnectionParameter(CONN_PARAM);
    connection->setTxPower(0);
    delay(1000);

    Serial.println();
    Serial.print("PHY ----------> "); Serial.println(connection->getPHY());
    Serial.print("Data length --> "); Serial.println(connection->getDataLength());
    Serial.print("MTU ----------> "); Serial.println(connection->getMtu());
    Serial.print("Interval -----> "); Serial.println(connection->getConnectionInterval());      
    
    char central_name[32] = { 0 };
    connection->getPeerName(central_name, sizeof(central_name));
    Serial.print("Connected to ");
    Serial.println(central_name);
    
    connectedFlag = true;
}




void disconnect_callback(uint16_t conn_handle, uint8_t reason) {
    (void) conn_handle;
    (void) reason;
    Serial.print("Disconnected, reason = 0x");
    Serial.println(reason, HEX);
    connectedFlag = false;
}

bool isConnected() {
    return connectedFlag;
}

void setupBLE() {
    Bluefruit.configUuid128Count(20);
    Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
    
    Bluefruit.begin();
    Bluefruit.setTxPower(0);
    Bluefruit.setName("CameraRelay");
    Bluefruit.setConnLedInterval(50);
    
    Bluefruit.Periph.setConnectCallback(connect_callback);
    Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

    serialService.begin();

    serialTxCharacteristic.setProperties(CHR_PROPS_NOTIFY);
    serialTxCharacteristic.setFixedLen(PACKET_SIZE);
    serialTxCharacteristic.begin();

    serialRxCharacteristic.setWriteCallback(serial_rx_callback);
    serialRxCharacteristic.begin();

    Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
    Bluefruit.Advertising.addTxPower();
    Bluefruit.Advertising.addService(serialService);
    Bluefruit.ScanResponse.addName();
    
    Bluefruit.Advertising.restartOnDisconnect(true);
    Bluefruit.Advertising.setIntervalMS(20, 153);
    Bluefruit.Advertising.setFastTimeout(30);
    Bluefruit.Advertising.start(0);
}

void serial_rx_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint8_t* data, uint16_t len) {
    Serial1.write(data, len);
}

void sendHandshake() {
    uint32_t totalBytes = FRAME_SIZE;
    uint16_t numPackets = NUM_PACKETS;
    uint16_t width = FRAME_WIDTH;
    uint16_t height = FRAME_HEIGHT;
    Serial.print("Sending ");
    Serial.print(NUM_PACKETS);
    Serial.println(" packets");
    // Create handshake packet
    uint8_t handshakePacket[14];  // 2+4+2+2+2+2 bytes
    handshakePacket[0] = 0xFF;
    handshakePacket[1] = 0xAA;
    memcpy(&handshakePacket[2], &totalBytes, 4);
    memcpy(&handshakePacket[6], &numPackets, 2);
    memcpy(&handshakePacket[8], &width, 2);
    memcpy(&handshakePacket[10], &height, 2);
    handshakePacket[12] = 0xFF;
    handshakePacket[13] = 0xBB;
    
    serialTxCharacteristic.notify(handshakePacket, 14);
}

void sendPacket(uint16_t packetNum, uint8_t* data, uint16_t dataSize) {
    // Create complete packet with header and data

    // Serial.print("Sending packet number:");
    // Serial.println(packetNum);
    uint8_t packet[PACKET_SIZE];
    memcpy(packet, &packetNum, 2);  // First 2 bytes are packet number
    memcpy(packet + 2, data, dataSize);  // Remaining bytes are data
    
    serialTxCharacteristic.notify(packet, PACKET_SIZE);
}


void sendBufferInPackets() {

    if (!isConnected() || !serialTxCharacteristic.notifyEnabled()) {
      return;
    }
    // Send handshake first
    sendHandshake();
    
    // Send data packets
    for (uint16_t i = 0; i < NUM_PACKETS; i++) {
        uint16_t offset = i * PACKET_DATA_SIZE;
        uint16_t remainingBytes = FRAME_SIZE - offset;
        uint16_t packetDataSize = min(remainingBytes, PACKET_DATA_SIZE);
        
        sendPacket(i, &buffer[offset], packetDataSize);
        delay(1);  // Small delay to prevent overwhelming the receiver
    }
}

void setup() {
    Serial.begin(115200);
    Serial1.begin(460800);
    setupBLE();
}

uint8_t dimensionBytes[4];

void loop() {
    while (Serial1.available()) {
      uint8_t inByte = Serial1.read();
      
      // Looking for start marker (0xFF 0xAA)
      if (!startFound) {
        if (lastByte == 0xFF && inByte == 0xAA) {
          startFound = true;
          Serial.println("Start received");
          bufferIndex = 0;
        }
        lastByte = inByte;
        continue;
      }
        
        // If we're here, we've found the start marker and are collecting data
      buffer[bufferIndex++] = inByte;
      Serial.println("Receiving all bytes");
      // Wait until we have all the data
      while (bufferIndex < FRAME_SIZE) {
        if (Serial1.available()) {
          buffer[bufferIndex++] = Serial1.read();
        }
      }

      Serial.print("Received ");
      Serial.print(bufferIndex);
      Serial.println(" bytes");
      
      // Once we have all the data, send it
      if (bufferIndex >= FRAME_SIZE) {
        Serial.println("Sending!");
        sendBufferInPackets();
        
        // Reset for next frame
        startFound = false;
        bufferIndex = 0;
        lastByte = 0;
        Serial.println("Sent!");
      } else {
        Serial.println("Not received the correct number of bytes to send");
      }
        
    }
}