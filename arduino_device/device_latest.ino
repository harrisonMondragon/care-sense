/*
    Base BLE peripheral code from https://docs.arduino.cc/tutorials/nano-33-ble-sense/ble-device-to-device
    other sources:

    This program uses the ArduinoBLE library to set-up an Arduino Nano 33 BLE Sense Rev2
    as a peripheral device and specifies a service and a characteristic for sound to connect to
    Garmin watch, acting as central.

*/

#include <ArduinoBLE.h>
#include <PDM.h>
#include <math.h>

// buffer to read samples into, each sample is 16-bits
short sampleBuffer[256];

// number of samples read
volatile int samplesRead;

// timer variables
unsigned long lastTime;
const unsigned long interval = 1000; // 1 second interval

// Threshold for considering a signal as noise
const double noiseThreshold = 80.0; // Adjust this value based on your environment

// Randomly generated using https://www.uuidgenerator.net/
const char *deviceServiceUuid = "5d390f04-f945-4b02-9e4a-307f6a53b492";
const char *deviceServiceCharacteristicUuid = "d7df8570-d653-4ff9-a473-0352de9d0e7c";

BLEService soundService(deviceServiceUuid);
BLEByteCharacteristic soundCharacteristic(deviceServiceCharacteristicUuid, BLERead | BLEWrite | BLENotify);

void onPDMdata();

void setup(){

    Serial.begin(9600);
    while (!Serial);

    // configure the data receive callback
    PDM.onReceive(onPDMdata);

    // initialize PDM with:
    // - one channel (mono mode)
    // - a 16 kHz sample rate
    if (!PDM.begin(1, 16000)){
        Serial.println("Failed to start PDM!");
        while (1);
    }

    // initialize lastTime
    lastTime = millis();

    if (!BLE.begin()){
        Serial.println("- Starting Bluetooth® Low Energy module failed!");
        while (1);
    }

    // Name will not be seen by Garmin watch, see:
    // https://forums.garmin.com/developer/connect-iq/f/discussion/279281/ble-device-names-null
    BLE.setLocalName("Sensory Device (local)");
    BLE.setDeviceName("Sensory Device");

    BLE.setAdvertisedService(soundService);
    soundService.addCharacteristic(soundCharacteristic);
    BLE.addService(soundService);
    soundCharacteristic.writeValue(20);
    BLE.advertise();

    Serial.println("Nano 33 BLE (Peripheral Device)");
    Serial.println(" ");
}

void loop(){

    BLEDevice central = BLE.central();
    Serial.println("- Discovering central device...");

    if (central){
        Serial.println("* Connected to central device!");
        Serial.print("* Device MAC address: ");
        Serial.println(central.address());
        Serial.println(" ");

        while (central.connected()){

            if (millis() - lastTime >= interval){
                // wait for samples to be read
                if (samplesRead){
                    // calculate the RMS amplitude
                    double sumSquared = 0.0;
                    for (int i = 0; i < samplesRead; i++){
                        sumSquared += pow(sampleBuffer[i], 2);
                    }
                    double rmsAmplitude = sqrt(sumSquared / samplesRead);

                    // Amplitude to dBFSs
                    float dBFS = 20 * log10(abs(rmsAmplitude));

                    // dBFS to Positive dB Scale
                    // -26 +- 1 dBFS is reference for 0 dB
                    float dB = dBFS + 25;
                    Serial.println("DB reading:" + String(dB));

                    soundCharacteristic.writeValue(dB);
                    //Serial.println("WRITTEN dB");

                    Serial.println("Subscribed value: " + String(soundCharacteristic.subscribed()));

                    // Compare dB against the noise threshold -- Will not be handled by device side for final MVP
                    // if (dB > noiseThreshold){
                    //     Serial.println("Loud noise detected!");
                    // } else {
                    //     Serial.println("Quiet environment.");
                    // }

                    // clear the read count
                    samplesRead = 0;

                    // update lastTime
                    lastTime = millis();
                }
            }
        }

        Serial.println("* Disconnected to central device!");
    }
}

void onPDMdata()
{
    // query the number of bytes available
    int bytesAvailable = PDM.available();

    // read into the sample buffer
    PDM.read(sampleBuffer, bytesAvailable);

    // 16-bit, 2 bytes per sample
    samplesRead = bytesAvailable / 2;
}
