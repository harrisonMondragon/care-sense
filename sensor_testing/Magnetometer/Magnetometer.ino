/*
  Arduino LSM9DS1 - Magnetometer

  This example reads the magnetometer's values from the LSM9DS1 sensor 
  and `analogWrite` the built-in LED according to the intensity of
  the magnetic field surrounding electrical devices.

  The circuit:
  - Arduino Nano 33 BLE Sense

  Created by Benjamin Dannegård
  4 Dec 2020

  This example code is in the public domain.
*/


#include <Arduino_LSM9DS1.h>
float x,y,z, ledvalue;

void setup() {
  IMU.begin();
}

void loop() {
  
  // read magnetic field in all three directions
  IMU.readMagneticField(x, y, z);
  
  if(x < 0)
  {
    ledvalue = -(x);
  }
  else{
    ledvalue = x;
  }
  
  analogWrite(LED_BUILTIN, ledvalue);
  delay(500);
}
