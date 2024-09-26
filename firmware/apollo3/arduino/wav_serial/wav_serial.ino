/* Author: @justiceamoh and Nathan Seidle
  Created: November 19th, 2019

  This example demonstrates how to read audio data and output
  it to a WAV file. This sketch outputs raw serial; an accompanying
  python script visualizes and coverts the raw data to a WAV file.

  Note: Audio samples are generated fast enough that we need to output
  serial at 500kbps.

  The PDM hardware is setup to take a sample every 64us (15.625kHz sample rate)
  The PDM library uses DMA to transfer 4096 bytes every 262ms and stores the
  data between two internal buffers. So check available() often and call getData
  to prevent buffer overruns.
*/

/* 
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
*/

#include <PDM.h> //Include PDM library included with the Aruino_Apollo3 core
AP3_PDM myPDM;   //Create instance of PDM class with our buffer

#define pdmDataSize 4096 //Library requires array be 4096
uint16_t pdmData[pdmDataSize];

// -----------------
// PDM Configuration
// -----------------
void *PDMHandle = NULL;
am_hal_pdm_config_t newConfig = {
    .eClkDivider = AM_HAL_PDM_MCLKDIV_1,
    .eLeftGain = AM_HAL_PDM_GAIN_0DB,
    .eRightGain = AM_HAL_PDM_GAIN_P90DB, //Found empirically
    .ui32DecimationRate = 48,            // OSR = 1500/16 = 96 = 2*SINCRATE --> SINC_RATE = 48
    .bHighPassEnable = 0,
    .ui32HighPassCutoff = 0xB,
    .ePDMClkSpeed = AM_HAL_PDM_CLK_375KHZ,
    .bInvertI2SBCLK = 0,
    .ePDMClkSource = AM_HAL_PDM_INTERNAL_CLK,
    .bPDMSampleDelay = 0,
    .bDataPacking = 1,
    .ePCMChannels = AM_HAL_PDM_CHANNEL_RIGHT,
    .ui32GainChangeDelay = 1,
    .bI2SEnable = 0,
    .bSoftMute = 0,
    .bLRSwap = 0,
};

void setup()
{
  Serial.begin(500000);
  delay(10);

  if (myPDM.begin() == false) // Turn on PDM with default settings, start interrupts
  {
    Serial.println("PDM Init failed. Are you sure these pins are PDM capable?");
    while (1)
      ;
  }
  myPDM.updateConfig(newConfig); //Send config struct
  printPDMConfig();
}

void loop()
{
  if (myPDM.available())
  {
    myPDM.getData(pdmData, pdmDataSize);

    //Print data to serial port
    Serial.write((uint8_t *)pdmData, sizeof(pdmData));
  }
}

void printPDMConfig(void)
{
  uint32_t PDMClk;
  uint32_t MClkDiv;
  float frequencyUnits;

  //
  // Read the config structure to figure out what our internal clock is set
  // to.
  //
  switch (myPDM.getClockDivider())
  {
  case AM_HAL_PDM_MCLKDIV_4:
    MClkDiv = 4;
    break;
  case AM_HAL_PDM_MCLKDIV_3:
    MClkDiv = 3;
    break;
  case AM_HAL_PDM_MCLKDIV_2:
    MClkDiv = 2;
    break;
  case AM_HAL_PDM_MCLKDIV_1:
    MClkDiv = 1;
    break;

  default:
    MClkDiv = 0;
  }

  switch (myPDM.getClockSpeed())
  {
  case AM_HAL_PDM_CLK_12MHZ:
    PDMClk = 12000000;
    break;
  case AM_HAL_PDM_CLK_6MHZ:
    PDMClk = 6000000;
    break;
  case AM_HAL_PDM_CLK_3MHZ:
    PDMClk = 3000000;
    break;
  case AM_HAL_PDM_CLK_1_5MHZ:
    PDMClk = 1500000;
    break;
  case AM_HAL_PDM_CLK_750KHZ:
    PDMClk = 750000;
    break;
  case AM_HAL_PDM_CLK_375KHZ:
    PDMClk = 375000;
    break;
  case AM_HAL_PDM_CLK_187KHZ:
    PDMClk = 187000;
    break;

  default:
    PDMClk = 0;
  }

  //
  // Record the effective sample frequency. We'll need it later to print the
  // loudest frequency from the sample.
  //
  int sampleFreq = (PDMClk / (MClkDiv * 2 * myPDM.getDecimationRate()));

  Serial.printf("Settings:\n");
  Serial.printf("PDM Clock (Hz):         %12d\n", PDMClk);
  Serial.printf("Decimation Rate:        %12d\n", myPDM.getDecimationRate());
  Serial.printf("Effective Sample Freq.: %12d\n", sampleFreq);
}