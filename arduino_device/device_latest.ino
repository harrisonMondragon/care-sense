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
#include <Arduino_HS300x.h>

// buffer to read samples into, each sample is 16-bits
short sampleBuffer[256];

// number of samples read
volatile int samplesRead;

// timer variables
unsigned long lastTime;
const unsigned long interval = 1000; // 1 second interval

// humidity and temp
float old_temp = 0;
// float old_hum = 0;

// Randomly generated using https://www.uuidgenerator.net/
const char *deviceServiceUuid = "5d390f04-f945-4b02-9e4a-307f6a53b492";
const char *soundCharacteristicUuid = "d7df8570-d653-4ff9-a473-0352de9d0e7c";
const char *tempCharacteristicUuid = "c4c7df1d-9cd1-4c15-aeb6-bdd362d8d344";

BLEService sensorService(deviceServiceUuid);
BLEByteCharacteristic soundCharacteristic(soundCharacteristicUuid, BLERead | BLENotify);
BLEByteCharacteristic temperatureCharacteristic(tempCharacteristicUuid, BLERead | BLENotify);

void onPDMdata();

void setup(){

    Serial.begin(9600);
    while (!Serial);

    // configure the data receive callback
    PDM.onReceive(onPDMdata);

    // initialize PDM with:
    // - one channel (mono mode), a 16 kHz sample rate
    if (!PDM.begin(1, 16000)){
        Serial.println("Failed to start PDM!");
        while (1);
    }

    if (!HS300x.begin()) {
      Serial.println("Failed to initialize humidity temperature sensor!");
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

    BLE.setAdvertisedService(sensorService);
    sensorService.addCharacteristic(soundCharacteristic);
    sensorService.addCharacteristic(temperatureCharacteristic);
    BLE.addService(sensorService);
    soundCharacteristic.writeValue(-1);
    temperatureCharacteristic.writeValue(-1);
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

            float temperature = HS300x.readTemperature();
            // float humidity = HS300x.readHumidity();

            if (millis() - lastTime >= interval){

                if (abs(old_temp - temperature) >= 0.5 ){
                    old_temp = temperature;
                    Serial.println("Temperature = " + String(temperature) + " °C");
                    temperatureCharacteristic.writeValue(temperature);
                }

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
