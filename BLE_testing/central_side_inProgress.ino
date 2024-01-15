/*
  BLE_Central_Device.ino

  This program uses the ArduinoBLE library to set-up an Arduino Nano 33 BLE Sense 
  as a central device and looks for a specified service and characteristic in a 
  peripheral device. If the specified service and characteristic is found in a 
  peripheral device, the last detected value of the on-board sound sensor of 
  the Nano 33 BLE Sense, the APDS9960, is written in the specified characteristic. 

  The circuit:
  - Arduino Nano 33 BLE Sense. 

  This example code is in the public domain.
*/

#include <ArduinoBLE.h>

const char* deviceServiceUuid = "19b10000-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristicUuid = "19b10001-e8f2-537e-4f6c-d104768a1214";

int sound = -1;
int oldsoundValue = -1;   

void setup() {
  Serial.begin(9600);
  while (!Serial);
  
  if (!BLE.begin()) {
    Serial.println("* Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  
  BLE.setLocalName("Nano 33 BLE (Central)"); 
  BLE.advertise();

  Serial.println("Arduino Nano 33 BLE Sense (Central Device)");
  Serial.println(" ");
}

void loop() {
  connectToPeripheral();
}

void connectToPeripheral(){
  BLEDevice peripheral;
  
  Serial.println("- Discovering peripheral device...");

  do
  {
    BLE.scanForUuid(deviceServiceUuid);
    peripheral = BLE.available();
  } while (!peripheral);
  
  if (peripheral) {
    Serial.println("* Peripheral device found!");
    Serial.print("* Device MAC address: ");
    Serial.println(peripheral.address());
    Serial.print("* Device name: ");
    Serial.println(peripheral.localName());
    Serial.print("* Advertised service UUID: ");
    Serial.println(peripheral.advertisedServiceUuid());
    Serial.println(" ");
    BLE.stopScan();
    controlPeripheral(peripheral);
  }
}

void controlPeripheral(BLEDevice peripheral) {
  Serial.println("- Connecting to peripheral device...");

  if (peripheral.connect()) {
    Serial.println("* Connected to peripheral device!");
    Serial.println(" ");
  } else {
    Serial.println("* Connection to peripheral device failed!");
    Serial.println(" ");
    return;
  }

  Serial.println("- Discovering peripheral device attributes...");
  if (peripheral.discoverAttributes()) {
    Serial.println("* Peripheral device attributes discovered!");
    Serial.println(" ");
  } else {
    Serial.println("* Peripheral device attributes discovery failed!");
    Serial.println(" ");
    peripheral.disconnect();
    return;
  }

  BLECharacteristic soundCharacteristic = peripheral.characteristic(deviceServiceCharacteristicUuid);
    
  if (!soundCharacteristic) {
    Serial.println("* Peripheral device does not have sound_type characteristic!");
    peripheral.disconnect();
    return;
  } else if (!soundCharacteristic.canWrite()) {
    Serial.println("* Peripheral does not have a writable sound_type characteristic!");
    peripheral.disconnect();
    return;
  }
  if (soundCharacteristic.canRead()) {
    Serial.println("SUBSCRIBING");
    Serial.println(soundCharacteristic.canSubscribe());
    soundCharacteristic.subscribe();
  }
  
  while(peripheral.connected()){
          soundCharacteristic.read();
            if(soundCharacteristic.valueUpdated()){
              if (soundCharacteristic.valueLength() >= 0) {
                Serial.println("value ");
                // sound = (byte)soundCharacteristic.value();
                // Serial.println(sound);
                printData(soundCharacteristic.value(), soundCharacteristic.valueLength());
                Serial.println();
              }
            }
        }
  Serial.println("Disconnecting ...");
  peripheral.disconnect();
  Serial.println("Disconnected");
  Serial.println("- Peripheral device disconnected!");
}
  
void printData(const unsigned char data[], int length) {
  for (int i = 0; i < length; i++) {
    unsigned char b = data[i];

    // if (b < 16) {
    //   Serial.print("0");
    // }
    Serial.print(b);
    // Serial.print(b, DEC);
  }
}
