#include <ArduinoBLE.h>
#include <PDM.h>

const char* deviceServiceUuid = "19b10000-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristicUuid = "19b10001-e8f2-537e-4f6c-d104768a1214";

int sound = -1;
int oldsoundValue = -1;   

short sampleBuffer[256];
// number of samples read
volatile int samplesRead;

void setup() {
  Serial.begin(9600);
  while (!Serial);
  
   // configure the data receive callback
  PDM.onReceive(onPDMdata);

  if (!PDM.begin(1, 16000)) {
    Serial.println("Failed to start PDM!");
    while (1);
  }
  
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
  
  while (peripheral.connected()) {
    sound = soundDetectection();

    if (oldsoundValue != sound) {  
      oldsoundValue = sound;
      Serial.print("* Writing value to sound_type characteristic: ");
      Serial.println(sound);
      soundCharacteristic.writeValue((byte)sound);
      Serial.println("* Writing value to sound_type characteristic done!");
      Serial.println(" ");
    }
  
  }
  Serial.println("- Peripheral device disconnected!");
}
  
int soundDetectection() {
  if (samplesRead) {
    // print samples to the serial monitor or plotter
    for (int i = 0; i < samplesRead; i++) {
      Serial.println(sampleBuffer[i]);
      // check if the sound value is higher than 500
      if (sampleBuffer[i]>=500){
        return 2;
      }
      // check if the sound value is higher than 250 and lower than 500
      if (sampleBuffer[i]>=250 && sampleBuffer[i] < 500){
        return 1;
      }
      //check if the sound value is higher than 0 and lower than 250
      if (sampleBuffer[i]>=0 && sampleBuffer[i] < 250){
        return 0;
      }
    }
    // clear the read count
    samplesRead = 0;
    return -1;
  }
}

void onPDMdata() {
  // query the number of bytes available
  int bytesAvailable = PDM.available();

  // read into the sample buffer
  // PDM is a digital representation of an analog signal - represent the amplitude of the audio signal
  PDM.read(sampleBuffer, bytesAvailable);

  // 16-bit, 2 bytes per sample
  samplesRead = bytesAvailable / 2;
}