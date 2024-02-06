/*
    This program uses the ArduinoBLE library to set-up an Arduino Nano 33 BLE Sense Rev2
    as a peripheral device and specifies a service and a characteristic for sound to connect to
    Garmin watch, acting as central.

    To help navigate states:
      - Red LED is on if we are in setup
      - Green LED is on if we are in loop but not connected to the watch
      - Blue LED is on if we are in loop and connected to the watch

    Sources:
        BLE tutorial: https://docs.arduino.cc/tutorials/nano-33-ble-sense/ble-device-to-device/
        Microphone tutorial: https://docs.arduino.cc/tutorials/nano-33-ble-sense/microphone-sensor/
        Root Mean Square Discussion: https://forum.arduino.cc/t/unable-to-get-arduinosound-library-to-work-with-nano-33-ble-boards/607559
*/

#include <ArduinoBLE.h>
#include <PDM.h>
#include <math.h>
#include <Arduino_HS300x.h>

// Timer variables
unsigned long lastTime;
const unsigned long interval = 1000; // 1 second interval

// Randomly generated UUIDs using https://www.uuidgenerator.net/
const char *deviceServiceUuid = "5d390f04-f945-4b02-9e4a-307f6a53b492";
const char *soundCharacteristicUuid = "d7df8570-d653-4ff9-a473-0352de9d0e7c";
const char *tempCharacteristicUuid = "c4c7df1d-9cd1-4c15-aeb6-bdd362d8d344";

// Create the service and characteristics
BLEService sensorService(deviceServiceUuid);
BLEByteCharacteristic soundCharacteristic(soundCharacteristicUuid, BLERead | BLENotify);
BLEByteCharacteristic temperatureCharacteristic(tempCharacteristicUuid, BLERead | BLENotify);


void setup(){

    // Set LED's pin to output mode
    pinMode(LEDR, OUTPUT);
    pinMode(LEDG, OUTPUT);
    pinMode(LEDB, OUTPUT);

    // Turn on only red LED if we are in setup
    digitalWrite(LEDR, LOW);
    digitalWrite(LEDG, HIGH);
    digitalWrite(LEDB, HIGH);

    // Initialize BLE (Bluetooth Low Energy module):
    if (!BLE.begin()){
        while (1);
    }

    // Name will not be seen by Garmin watch, see:
    // https://forums.garmin.com/developer/connect-iq/f/discussion/279281/ble-device-names-null
    BLE.setLocalName("Sensory Device (local)");
    BLE.setDeviceName("Sensory Device");

    // Set service UUID and add characteristics to it
    BLE.setAdvertisedService(sensorService);
    sensorService.addCharacteristic(soundCharacteristic);
    sensorService.addCharacteristic(temperatureCharacteristic);

    // Add service and set initial values
    BLE.addService(sensorService);
    soundCharacteristic.writeValue(-1);
    temperatureCharacteristic.writeValue(-1);

    // Start advertising
    BLE.advertise();

    // Initialize lastTime
    lastTime = millis();
}

void loop(){

    // Turn on only green LED if we are in loop but not connected to watch
    digitalWrite(LEDR, HIGH);
    digitalWrite(LEDG, LOW);
    digitalWrite(LEDB, HIGH);

    BLEDevice central = BLE.central();

    if (central){

        // Turn on only blue LED if we are in loop and connected to watch
        digitalWrite(LEDR, HIGH);
        digitalWrite(LEDG, HIGH);
        digitalWrite(LEDB, LOW);

        int dummy = 0;
        while (central.connected()){

            // Send fake data as dB, will just increment every second
            // Resets at 70 so it will not trigger watch sound notifications
            if (millis() - lastTime >= interval){

                // Write dummy
                soundCharacteristic.writeValue(dummy);

                // Update dummy
                dummy++;
                if(dummy >= 70){
                    dummy = 0;
                }

                // Update lastTime;
                lastTime = millis();
            }
        }

        // Immediately when the central disconnects, turn off the blue LED
        digitalWrite(LEDB, HIGH);
    }
}