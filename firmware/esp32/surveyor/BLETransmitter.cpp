#include "BLETransmitter.h"
// // // BLE service and characteristic UUIDs


class ServerCallbacks : public BLEServerCallbacks
{
public:
    ServerCallbacks(BLETransmitter* transmitter) : m_transmitter(transmitter) {}

    void onConnect(BLEServer* pServer, esp_ble_gatts_cb_param_t* param) override
    {
        m_transmitter->setDeviceConnected(true);
        
        // Get and print the address of the connected client
        char address_str[18];
        sprintf(address_str, "%02x:%02x:%02x:%02x:%02x:%02x",
                param->connect.remote_bda[0], param->connect.remote_bda[1],
                param->connect.remote_bda[2], param->connect.remote_bda[3],
                param->connect.remote_bda[4], param->connect.remote_bda[5]);
        
        Serial.print("Connected client address: ");
        Serial.println(address_str);
    }

    void onDisconnect(BLEServer* pServer) override
    {
        m_transmitter->setDeviceConnected(false);
    }

private:
    BLETransmitter* m_transmitter;
};

void AckCharacteristicCallbacks::onWrite(BLECharacteristic *pCharacteristic)
{
    if (pCharacteristic == nullptr) {
        Serial.println("Error: Null characteristic in onWrite callback");
        return;
    }
    
    std::string value = pCharacteristic->getValue();
    size_t len = value.length();
    
    if (len == 2)
    {
        uint16_t ackedPacket = (uint16_t)((uint8_t)value[0] << 8 | (uint8_t)value[1]);
        // Serial.printf(" Received ack for packet %d\n", ackedPacket);
        
        if (m_transmitter != nullptr) {
            m_transmitter->setAckBit(ackedPacket);
        } else {
            Serial.println("Error: Null m_transmitter in onWrite callback");
        }
    } 
}

void BLETransmitter::setAckBit(uint16_t packetIndex)
{
    // if (packetIndex < MAX_PACKETS)
    // {
        // m_ackBitmap[packetIndex / 8] |= (1 << (packetIndex % 8));
        m_ackBitmap[packetIndex] = 1;
    // }
}

BLETransmitter::BLETransmitter(SDCard &sd) 
    : sdCard(sd), sendFileTaskHandle(NULL), m_deviceConnected(false), m_ackBitmap(NULL)
{
    // m_ackBitmap = (uint8_t *)ps_calloc(4000, sizeof(uint8_t));
    m_ackBitmap = (uint8_t*)heap_caps_malloc(4000, MALLOC_CAP_8BIT | MALLOC_CAP_INTERNAL);
    memset(m_ackBitmap, 0, 4000);
    if (m_ackBitmap == NULL) {
        Serial.println("Failed to allocate memory for ackBitmap");
    }
    
    // m_ackBitmap_copy = (uint8_t *)ps_calloc(BITMAP_SIZE, sizeof(uint8_t));
    // if (m_ackBitmap_copy == NULL) {
    //     Serial.println("Failed to allocate memory for ackBitmap_copy");
    // }
}

BLETransmitter::~BLETransmitter()
{
    if (m_ackBitmap != NULL) {
        free(m_ackBitmap);
    }
}


bool BLETransmitter::begin()
{
    BLEDevice::init("OpenSurveyor");
    // setPHY();
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks(this));

    pService = pServer->createService(serviceUUID);

    fileDataCharacteristic = pService->createCharacteristic(
        fileDataUUID,
        BLECharacteristic::PROPERTY_READ |
            BLECharacteristic::PROPERTY_NOTIFY);
    fileDataCharacteristic->addDescriptor(new BLE2902());

    ackCharacteristic = pService->createCharacteristic(
        ackUUID,
        BLECharacteristic::PROPERTY_WRITE);
    ackCharacteristic->setCallbacks(new AckCharacteristicCallbacks(this));

    pService->start();

    pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(serviceUUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    pAdvertising->setMaxPreferred(0x12);

    BLEDevice::startAdvertising();
    Serial.println("BLE started.");
    return true;
}

void BLETransmitter::setPHY()
{
    ext_adv_params_1M.type = ESP_BLE_GAP_SET_EXT_ADV_PROP_CONNECTABLE;
    ext_adv_params_1M.channel_map = ADV_CHNL_ALL;
    ext_adv_params_1M.filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY;
    ext_adv_params_1M.primary_phy = ESP_BLE_GAP_PHY_1M;
    ext_adv_params_1M.max_skip = 0;
    ext_adv_params_1M.secondary_phy = ESP_BLE_GAP_PHY_2M;
    ext_adv_params_1M.sid = 0;
    ext_adv_params_1M.scan_req_notif = false;
    ext_adv_params_1M.own_addr_type = BLE_ADDR_TYPE_PUBLIC;

    // Setup extended advertising parameters for 2M PHY
    memcpy(&ext_adv_params_2M, &ext_adv_params_1M, sizeof(esp_ble_gap_ext_adv_params_t));
    ext_adv_params_2M.primary_phy = ESP_BLE_GAP_PHY_2M;

    // Set up connection parameters for 1M PHY
    conn_params_1M.scan_interval = 0x40;
    conn_params_1M.scan_window = 0x40;
    conn_params_1M.interval_min = 0x18; // 30ms
    conn_params_1M.interval_max = 0x28; // 50ms
    conn_params_1M.latency = 0;
    conn_params_1M.supervision_timeout = 400; // 4s

    // Set up connection parameters for 2M PHY
    memcpy(&conn_params_2M, &conn_params_1M, sizeof(esp_ble_gap_conn_params_t));
    conn_params_2M.interval_min = 0x18; // 30ms
    conn_params_2M.interval_max = 0x28; // 50ms

    // Set extended advertising parameters
    esp_ble_gap_ext_adv_set_params(0, &ext_adv_params_1M);
    esp_ble_gap_ext_adv_set_params(1, &ext_adv_params_2M);

    // Set preferred PHYs
    esp_ble_gap_set_prefered_default_phy(ESP_BLE_GAP_PHY_OPTIONS_PREF_S2_CODING, ESP_BLE_GAP_PHY_OPTIONS_PREF_S2_CODING);

    // Set preferred connection parameters
    esp_ble_gap_prefer_ext_connect_params_set(NULL,
                                              ESP_BLE_GAP_PHY_1M_PREF_MASK | ESP_BLE_GAP_PHY_2M_PREF_MASK,
                                              &conn_params_1M, &conn_params_2M, NULL);
}

void BLETransmitter::startBleServer()
{
    xTaskCreatePinnedToCore(
        this->sendFileTask,
        "BLETask",
        10000,
        this,
        1,
        &sendFileTaskHandle,
        1 // Run on core 1
    );
}

void BLETransmitter::sendFileTask(void *pvParameters)
{
    BLETransmitter *transmitter = static_cast<BLETransmitter *>(pvParameters);
    for (;;)
    {
        Serial.println("Checking for files to transmit...");
        transmitter->transmitFiles();
        vTaskDelay(pdMS_TO_TICKS(SEND_FILE_INTERVAL));
    }
}

void BLETransmitter::transmitFiles()
{
    if (fileSent)
    {
        return;
    }
    if (!m_deviceConnected) {
        Serial.println("Device not connected, skipping file transmission.");
        return;
    }

    

    String filename;
    // if (sdCard.acquireNextFile(filename)) {
    //     Serial.printf("Acquired file: %s\n", filename.c_str());
    // } else {
    //     Serial.println("No files to transmit.");
    // }
    // String
    filename = "/arduino_rec_1.wav";
    // filename = "/image3.jpg";
    size_t fileSize = sdCard.getFileSize(filename);
    if (fileSize == 0)
    {
        Serial.println("File size is 0, skipping file transmission.");
        return;
    }
    // Send packet 0 with filename and number of frames
    uint16_t numFrames = (fileSize + MAX_FRAME_SIZE - 1) / MAX_FRAME_SIZE + 1;
    Serial.printf("Transmitting file: %s, size: %d, frames: %d, time: %d\n", filename.c_str(), fileSize, numFrames);
    uint32_t startTime = millis();
    // Serial.printf("Sending first frame\n");
    sendPacket(0, reinterpret_cast<const uint8_t *>(filename.c_str()), filename.length() + 1, numFrames);

    uint8_t frameBuffer[MAX_FRAME_SIZE];
    size_t bytesRead;
    uint16_t frameIndex = 1;
    // Serial.printf("Sending rest of frames\n");
    if (sdCard.readFile(filename, frameBuffer, 0, MAX_FRAME_SIZE, bytesRead))
    {
        while (bytesRead > 0)
        {
            bytesRead = 0;
            if (m_ackBitmap[frameIndex] == 0) {
                if (sdCard.readFile(filename, frameBuffer, (frameIndex - 1) * MAX_FRAME_SIZE, MAX_FRAME_SIZE, bytesRead))
                {
                    sendPacket(frameIndex, frameBuffer, bytesRead);
                }
                else
                {
                    Serial.printf("No more data to read: %s\n", filename.c_str());
                    break;
                }
            }
            frameIndex++;
        }
    }
    else
    {
        Serial.printf("Error opening file: %s\n", filename.c_str());
    }

    // Send last packet with closing signature
    static const uint8_t signature[] = "END";
    sendPacket(frameIndex, signature, sizeof(signature));

    // sdCard.removeFile(filename);
    uint32_t endTime = millis();
    uint32_t duration = endTime - startTime;
    Serial.printf("Transmitting file complete: %s, time: %d\n", filename.c_str(), duration);
    // fileSent = true;
}

void BLETransmitter::sendPacket(uint16_t packetIndex, const uint8_t *data, size_t length, uint16_t numFrames)
{
    uint8_t packet[MAX_PACKET_SIZE];
    size_t packetSize = 0;

    packet[0] = packetIndex & 0xFF;
    packet[1] = (packetIndex >> 8) & 0xFF;
    packet[2] = 0;

    packetSize = 3;

    if (packetIndex == 0)
    {
        packet[packetSize++] = numFrames >> 8;
        packet[packetSize++] = numFrames & 0xFF;

        // Add current millis time to the starting packet
        uint32_t currentMillis = millis();
        packet[packetSize++] = (currentMillis >> 24) & 0xFF;
        packet[packetSize++] = (currentMillis >> 16) & 0xFF;
        packet[packetSize++] = (currentMillis >> 8) & 0xFF;
        packet[packetSize++] = currentMillis & 0xFF;
    }

    memcpy(packet + packetSize, data, length);
    packetSize += length;
    fileDataCharacteristic->setValue(packet, packetSize);
    fileDataCharacteristic->notify();
    // Serial.printf("Sent packet %d\n", packetIndex);
}