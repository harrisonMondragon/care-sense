/*
  BLE_Peripheral.ino

  This program uses the ArduinoBLE library to set-up an Arduino Nano 33 BLE
  as a peripheral device and specifies a service and a characteristic. Depending
  of the value of the specified characteristic, an on-board LED gets on.

  The circuit:
  - Arduino Nano 33 BLE.

  This example code is in the public domain.
*/

#include <ArduinoBLE.h>
#include <PDM.h>

// buffer to read samples into, each sample is 16-bits
short sampleBuffer[256];

// number of samples read
volatile int samplesRead;

// timer variables
unsigned long lastTime;
const unsigned long interval = 1000; // 1 second interval

// Threshold for considering a signal as noise
const double noiseThreshold = 100.0; // Adjust this value based on your environment

const char* deviceServiceUuid = "5d390f04-f945-4b02-9e4a-307f6a53b492";
const char* deviceServiceCharacteristicUuid = "d7df8570-d653-4ff9-a473-0352de9d0e7c";

int sound = -1;

BLEService soundService(deviceServiceUuid);
BLEByteCharacteristic soundCharacteristic(deviceServiceCharacteristicUuid, BLERead | BLEWrite | BLENotify );

// Needed for notifications
BLEDescriptor soundDescriptor("2902", "sound");

int connection_testing_counter = 0;

// void onPDMdata();

void setup() {
  Serial.begin(9600);
  while (!Serial);


  // PDM.onReceive(onPDMdata);
  // if (!PDM.begin(1, 16000)) {
  //   Serial.println("Failed to start PDM!");
  //   while (1);
  // }
  // initialize lastTime
  lastTime = millis();

  if (!BLE.begin()) {
    Serial.println("- Starting Bluetooth® Low Energy module failed!");
    while (1);
  }

  // Name will not be seen by Garmin watch, see:
  // https://forums.garmin.com/developer/connect-iq/f/discussion/279281/ble-device-names-null
  BLE.setLocalName("Harry's Arduino (local)");
  BLE.setDeviceName("Harry's Arduino");

  // Needed for notifications
  soundCharacteristic.addDescriptor(soundDescriptor);
  BLE.setAdvertisedService(soundService);
  soundService.addCharacteristic(soundCharacteristic);
  BLE.addService(soundService);
  soundCharacteristic.writeValue(20);
  BLE.advertise();

  Serial.println("Nano 33 BLE (Peripheral Device)");
  Serial.println(" ");
}

void loop() {
  BLEDevice central = BLE.central();
  //Serial.println("- Discovering central device...");

  if (central) {
    Serial.println("* Connected to central device!");
    Serial.print("* Device MAC address: ");
    Serial.println(central.address());
    Serial.println(" ");

    while (central.connected()) {

      soundCharacteristic.writeValue((byte)connection_testing_counter);
      Serial.println("WRITTEN");
      Serial.println(connection_testing_counter);

      delay(1000);
      connection_testing_counter++;

      if (connection_testing_counter > 150){
        connection_testing_counter = 0;
      }

      // if (millis() - lastTime >= interval) {

      //   // wait for samples to be read
      //   if (samplesRead) {
      //     // calculate the RMS amplitude
      //     double sumSquared = 0.0;
      //     for (int i = 0; i < samplesRead; i++) {
      //       sumSquared += pow(sampleBuffer[i], 2);
      //     }
      //     double rmsAmplitude = sqrt(sumSquared / samplesRead);

      //     soundCharacteristic.writeValue((byte)rmsAmplitude);
      //     Serial.println("WRITTEN");
      //     Serial.println(rmsAmplitude);

      //     // clear the read count
      //     samplesRead = 0;

      //     // update lastTime
      //     lastTime = millis();
      //   }
      // }
    }

    Serial.println("* Disconnected to central device!");
  }
}

void onPDMdata() {
  // query the number of bytes available
  int bytesAvailable = PDM.available();

  // read into the sample buffer
  PDM.read(sampleBuffer, bytesAvailable);

  // 16-bit, 2 bytes per sample
  samplesRead = bytesAvailable / 2;
}

