// ble.cpp
#include "ble.h"
#include "state.h"

BLEService aspireService(ASPIRE_SERVICE_UUID);
BLECharacteristic speakerRxCharacteristic(SPEAKER_RX_UUID, BLEWrite | BLEWriteWithoutResponse, PACKET_SIZE);
BLECharacteristic micDataSendCharacteristic(CAM_TX_UUID, BLENotify, PACKET_SIZE);
BLECharacteristic micTxCharacteristic(MIC_TX_UUID, BLERead | BLENotify, PACKET_SIZE);

static bool connectedFlag = false;

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

void speaker_rx_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint8_t* data, uint16_t len) {
  receiveAudio(data, len);
}

bool isConnected() {
    return connectedFlag;
}

void setupBLE() {
    Bluefruit.configUuid128Count(20);
    Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
    
    Bluefruit.begin();
    Bluefruit.setTxPower(0);
    Bluefruit.setName("Aspire");
    Bluefruit.setConnLedInterval(50);
    
    Bluefruit.Periph.setConnectCallback(connect_callback);
    Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

    // Setup Serial Service
    aspireService.begin();
    micDataSendCharacteristic.setProperties(CHR_PROPS_NOTIFY);
    micDataSendCharacteristic.setFixedLen(PACKET_SIZE);
    micDataSendCharacteristic.begin();

    speakerRxCharacteristic.setWriteCallback(speaker_rx_callback);
    speakerRxCharacteristic.begin();

    micTxCharacteristic.setProperties(CHR_PROPS_NOTIFY);
    micTxCharacteristic.setFixedLen(PACKET_SIZE);
    micTxCharacteristic.begin();


    // Configure advertising
    Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
    Bluefruit.Advertising.addTxPower();
    Bluefruit.Advertising.addService(aspireService);
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
    
    micDataSendCharacteristic.notify(handshakePacket, 14);
}

void sendPacket(uint16_t packetNum, uint8_t* data, uint16_t dataSize) {
    uint8_t packet[PACKET_SIZE];
    memcpy(packet, &packetNum, 2);
    memcpy(packet + 2, data, dataSize);
    micDataSendCharacteristic.notify(packet, dataSize+2);
}

uint32_t fletcher32(uint8_t const *data, size_t len) {
    uint32_t sum1 = 0xffff, sum2 = 0xffff;
    
    while (len > 1) {
        size_t blocks = (len > 718) ? 718 : len;
        len -= blocks;
        blocks /= 2;  // Process two bytes at a time
        
        while (blocks) {
            uint16_t word = (data[0] << 8) | data[1];
            sum1 += word;
            sum2 += sum1;
            data += 2;
            blocks--;
        }
        
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    if (len) {
        sum1 += (*data << 8);
        sum2 += sum1;
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    sum1 = (sum1 & 0xffff) + (sum1 >> 16);
    sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    
    return (sum2 << 16) | sum1;
}
