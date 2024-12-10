#include "esp_camera.h"
#include <WiFi.h>
#include <HTTPClient.h>

#define CAMERA_MODEL_XIAO_ESP32S3 // Has PSRAM

#include "camera_pins.h"

// WiFi credentials
const char* ssid = "Castro Hotel";
const char* password = "castro12684";

// Supabase configuration
const char* supabaseUrl = "https://sycpmqwjdcbdbsoqowaj.supabase.co";
const char* supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5Y3BtcXdqZGNiZGJzb3Fvd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5MjkyMDksImV4cCI6MjA0MTUwNTIwOX0.ZkxKGOlzV6Ut1zPyGGjKHA2Nd16uPWCty-Cf8y26dCU";
const char* bucketName = "desktop";

// NTP Server
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = -25200;  // GMT-7 for California (in seconds)
const int   daylightOffset_sec = 3600;  // 1 hour of daylight saving time

bool camera_sign = false;

// Menu state
enum MenuState {
  MAIN_MENU,
  FRAME_SIZE_MENU,
  QUALITY_MENU,
  EFFECT_MENU,
  WHITE_BALANCE_MENU,
  EXPOSURE_MENU
};

MenuState currentMenu = MAIN_MENU;

void configure_camera() {
  // Camera configuration
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.frame_size = FRAMESIZE_UXGA;
  config.pixel_format = PIXFORMAT_JPEG;
  config.grab_mode = CAMERA_GRAB_WHEN_EMPTY;
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.jpeg_quality = 12;
  config.fb_count = 1;

  if(config.pixel_format == PIXFORMAT_JPEG){
    if(psramFound()){
      config.jpeg_quality = 10;
      config.fb_count = 2;
      config.grab_mode = CAMERA_GRAB_LATEST;
    } else {
      config.frame_size = FRAMESIZE_SVGA;
      config.fb_location = CAMERA_FB_IN_DRAM;
    }
  } else {
    config.frame_size = FRAMESIZE_240X240;
#if CONFIG_IDF_TARGET_ESP32S3
    config.fb_count = 2;
#endif
  }

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  camera_sign = true;
  Serial.println("Camera initialized");
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED off
}

void uploadToSupabase(camera_fb_t *fb, const char* uploadPath) {
  if (!fb) {
    Serial.println("Camera capture failed");
    return;
  }

  HTTPClient http;
  String url = String(supabaseUrl) + "/storage/v1/object/" + bucketName + "/1/esp32/" + uploadPath;
  http.begin(url);
  http.addHeader("Authorization", "Bearer " + String(supabaseKey));
  http.addHeader("Content-Type", "image/jpeg");

  int httpResponseCode = http.sendRequest("POST", (uint8_t*)fb->buf, fb->len);

  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println(httpResponseCode);
    Serial.println(response);
  } else {
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
  }

  http.end();
}

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED on
  Serial.begin(115200);
  // while(!Serial);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  // Init and get the time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  configure_camera();
}

void takePicture() {
  if(!camera_sign) {
    Serial.println("Camera not initialized");
    return;
  }

  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }

  char dateFolder[9];
  char timeFile[11];
  char fullPath[32];
  strftime(dateFolder, sizeof(dateFolder), "%Y%m%d", &timeinfo);
  strftime(timeFile, sizeof(timeFile), "%H%M%S.jpg", &timeinfo);
  snprintf(fullPath, sizeof(fullPath), "/%s/%s", dateFolder, timeFile);

  // Capture and upload photo
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED on while taking picture
  camera_fb_t *fb = esp_camera_fb_get();
  uploadToSupabase(fb, fullPath);
  esp_camera_fb_return(fb);
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED off after taking picture
  
  Serial.println("Photo captured and uploaded");
}

void loop() {
  
  delay(30000);
  Serial.println("Taking picture...");
  takePicture();
  // Serial.println("Next photo in five minutes.");
  Modem_Sleep_enable();
  Deep_Sleep_Function();
}

RTC_DATA_ATTR int bootCount = 0;
#define uS_TO_S_FACTOR 1000000ULL /* Conversion factor for micro seconds to seconds */
#define TIME_TO_SLEEP  300
void print_wakeup_reason() {
  esp_sleep_wakeup_cause_t wakeup_reason;
  wakeup_reason = esp_sleep_get_wakeup_cause();

  switch (wakeup_reason) {
    case ESP_SLEEP_WAKEUP_EXT0:     Serial.println("Wakeup caused by external signal using RTC_IO"); break;
    case ESP_SLEEP_WAKEUP_EXT1:     Serial.println("Wakeup caused by external signal using RTC_CNTL"); break;
    case ESP_SLEEP_WAKEUP_TIMER:    Serial.println("Wakeup caused by timer"); break;
    case ESP_SLEEP_WAKEUP_TOUCHPAD: Serial.println("Wakeup caused by touchpad"); break;
    case ESP_SLEEP_WAKEUP_ULP:      Serial.println("Wakeup caused by ULP program"); break;
    default:                        Serial.printf("Wakeup was not caused by deep sleep: %d\n", wakeup_reason); break;
  }
}

void Deep_Sleep_Function() {
  ++bootCount;
  Serial.println("Boot number: " + String(bootCount));
  print_wakeup_reason();
  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
  Serial.println("Setup ESP32 to sleep for every " + String(TIME_TO_SLEEP) + " Seconds");
  Serial.println("Going to deep sleep now");
  Serial.flush();
  esp_deep_sleep_start();
}

void Modem_Sleep_enable() {
  WiFi.mode(WIFI_OFF);
  if (WiFi.getMode() == WIFI_OFF) {
    Serial.println("WiFi is off");
  } else {
    Serial.println("WiFi is still on");
  }
}



