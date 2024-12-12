#include "cam.h"

static SLIC slic;
uint8_t pixels[BUFFER_SIZE];
uint8_t compressedBuffer[BUFFER_SIZE];

void setupCamera() {
  Serial.println("Initializing Camera");
  if (hm01b0_init(&hm01b0_config) != 0) {
    Serial.println("Failed to initialize camera!");
    while(true) {}
  }
  Serial.println("Camera Initialized");
}

void sendImage() {
  digitalWrite(8, HIGH);
  int startTime = millis();
  hm01b0_read_frame(pixels, sizeof(pixels));

   // Initialize SLIC encoder for grayscale image (8bpp)
  int rc = slic.init_encode_ram(IMAGE_WIDTH, IMAGE_HEIGHT, 8, NULL, 
                              compressedBuffer, BUFFER_SIZE);
  
  if (rc != SLIC_SUCCESS) {
    Serial.print("SLIC initialization failed with error: ");
    Serial.println(rc);
  } else {
    // Encode the entire image
    rc = slic.encode(pixels, IMAGE_WIDTH * IMAGE_HEIGHT);
        
    if (rc == SLIC_DONE) {
      
    //   // Get the size of compressed data
      uint32_t compressedSize = slic.get_output_size();
      Serial.printf("Compressed size: %d\n", compressedSize);

      delay(10);
      Serial1.write(0xFF);
      Serial1.write(0xAA);
      Serial1.write(0xFF);
      Serial1.write(0xAA);
      
      // Serial1.write((uint8_t*)&compressedSize, sizeof(compressedSize));
      // bool written = writeChunked(compressedBuffer, compressedSize);
      // uint32_t checksum = fletcher32(compressedBuffer, compressedSize);
      
      uint32_t pixelSize = BUFFER_SIZE;
      Serial1.write((uint8_t*)&pixelSize, sizeof(pixelSize));
      bool written = writeChunked(pixels, pixelSize);
      uint32_t checksum = fletcher32(pixels, pixelSize);
      
      Serial.printf("Fletcher-32 checksum: 0x%08X\n", checksum);

      if (written) {
        delay(10);
        Serial.print("Sent in ");
        Serial.println(millis()-startTime);
      } else {
        Serial.println("Write failed, NRF isn't responding");
      }

      
    } else {
      Serial.print("SLIC encoding failed with error: ");
      Serial.println(rc);
    }
  }
  digitalWrite(8, LOW);
}

bool writeChunked(uint8_t* buffer, size_t totalSize) {
    
    const uint8_t CHUNK_START_MARKER[] = {0xFF, 0xCC, 0xFF, 0xCC};
    const uint8_t CHUNK_END_MARKER[] = {0xFF, 0xDD, 0xFF, 0xDD};
    
    size_t bytesRemaining = totalSize;
    size_t offset = 0;
    uint8_t ackByte;
    uint16_t chunk_index = 0;
    int total_retries = 0;

    Serial.printf("Sending %d bytes in %d chunks\n", totalSize, totalSize/CHUNK_SIZE);
    // Serial.printf("In hex 0x%08lX\n", totalSize, totalSize);
    while (bytesRemaining > 0) {
        // Calculate size of next chunk
        size_t chunkSize = min(CHUNK_SIZE, bytesRemaining);
        bool chunkAcked = false;
        // Serial.printf("Sending chunk %d, size: %d\n", chunk_index, chunkSize);
        int tries = 0;
        
        while (!chunkAcked) {
            // Send chunk marker
            Serial1.write(CHUNK_START_MARKER, 4);
            
            // Write chunk
            Serial1.write(buffer + offset, chunkSize);

            Serial1.write(CHUNK_END_MARKER, 4);
            
            // Wait for ACK
            unsigned long startTime = millis();
            while (millis() - startTime < ACK_TIMEOUT_MS) {
                if (Serial1.available()) {
                    ackByte = Serial1.read();
                    if (ackByte == 0xAC) {
                        chunkAcked = true;
                        // Serial.println("Ack received");
                        chunk_index++;
                        break;
                    }
                }
            }
            if(!chunkAcked) {
              tries++;
              // Serial.printf("Sending chunk %d again\n", chunk_index);
              total_retries++;
            }
            if(tries > ACK_RETRIES) {
              return false;
            }
        }
        
        // Update tracking variables
        offset += chunkSize;
        bytesRemaining -= chunkSize;
    }
    Serial.printf("Total Retries: %d\n", total_retries);
    return true;
}