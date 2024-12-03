#include <bluefruit.h>

// BLE Service UUIDs
#define SERIAL_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_RX_UUID      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define SERIAL_TX_UUID      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

// Constants
#define MTU             240
#define FRAME_WIDTH     160
#define FRAME_HEIGHT    120
#define FRAME_SIZE      (FRAME_WIDTH * FRAME_HEIGHT)
#define BUFFER_SIZE     (FRAME_SIZE + 4)  // Frame data + start/end markers
#define DATA_NUM        240  // Maximum data length for BLE packet
#define CONN_PARAM      6    // Connection interval parameter

// BLE Service and Characteristics
BLEService serialService(SERIAL_SERVICE_UUID);
BLECharacteristic serialRxCharacteristic(SERIAL_RX_UUID, BLEWrite | BLEWriteWithoutResponse, MTU);
BLECharacteristic serialTxCharacteristic(SERIAL_TX_UUID, BLENotify, MTU);

// Frame buffer and state
uint8_t frameBuffer[BUFFER_SIZE];
int bufferIndex = 0;
bool startFound = false;
bool collecting = false;
bool connectedFlag = false;

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
    // Increase UUID count to accommodate both services
    Bluefruit.configUuid128Count(20);
    Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
    
    Bluefruit.begin();
    Bluefruit.setTxPower(0);
    Bluefruit.setName("CameraRelay");
    Bluefruit.setConnLedInterval(50);
    
    // Set callbacks
    Bluefruit.Periph.setConnectCallback(connect_callback);
    Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

    // Configure the Serial service
    serialService.begin();

    // Configure characteristics
    serialTxCharacteristic.setProperties(CHR_PROPS_NOTIFY);
    serialTxCharacteristic.setFixedLen(DATA_NUM);
    serialTxCharacteristic.begin();

    serialRxCharacteristic.setWriteCallback(serial_rx_callback);
    serialRxCharacteristic.begin();

    // Configure advertising
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

void sendFrameOverBLE() {
    if (!isConnected() || !serialTxCharacteristic.notifyEnabled()) {
        return;
    }

    // Send start marker
    serialTxCharacteristic.notify(&frameBuffer[0], 2);
    delay(5);

    // Send frame data in chunks
    for (int i = 2; i < FRAME_SIZE + 2; i += DATA_NUM) {
        int chunkSize = min(DATA_NUM, FRAME_SIZE + 2 - i);
        serialTxCharacteristic.notify(&frameBuffer[i], chunkSize);
        delay(5);  // Small delay between chunks
    }

    // Send end marker
    serialTxCharacteristic.notify(&frameBuffer[FRAME_SIZE + 2], 2);
}

void setup() {
    Serial.begin(115200);  // Debug serial
    Serial1.begin(921600); // Hardware Serial from RP2040
    setupBLE();
}

void loop() {
    while (Serial1.available()) {
        uint8_t inByte = Serial1.read();
        
        // Looking for start marker
        if (!startFound) {
            frameBuffer[0] = frameBuffer[1];
            frameBuffer[1] = inByte;
            
            if (frameBuffer[0] == 0xFF && frameBuffer[1] == 0xAA) {
                startFound = true;
                collecting = true;
                bufferIndex = 2;
            }
            continue;
        }
        
        // Collecting frame data
        if (collecting) {
            frameBuffer[bufferIndex++] = inByte;
            
            if (bufferIndex >= BUFFER_SIZE) {
                collecting = false;
                startFound = false;
                
                if (isConnected()) {
                    sendFrameOverBLE();
                }
                
                bufferIndex = 0;
            }
        }
    }
}