// ble.cpp
#include "ble.h"

// BLE Service and Characteristics
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

void serial_rx_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint8_t* data, uint16_t len) {
    Serial1.write(data, len);
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

void sendHandshake(uint32_t totalBytes, uint16_t numPackets, uint16_t width, uint16_t height) {
    
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
    uint8_t packet[PACKET_SIZE];
    memcpy(packet, &packetNum, 2);
    memcpy(packet + 2, data, dataSize);
    
    serialTxCharacteristic.notify(packet, PACKET_SIZE);
}
