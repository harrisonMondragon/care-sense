This basic sketch allows us to connect a to the Nano via a phone app. It is the code from:
https://docs.arduino.cc/tutorials/nano-33-ble/bluetooth

I used nRF connect, but other apps probably work as well.

Steps tp follow:
    1) Flash the BLE.ino code onto Nano
    2) Start the serial monitor for BLE LED Peripheral
    3) Open nRF connect and find "Nano 33 BLE"
    4) Connect to the device, an orange LED should light up
    5) Go to the "Client" page within the connection. It should show "Advertised Services" and
       "Attribiute Table" populated with information from BLE.ino (service UUID 180A)
    6) In the "Attribute Table" press the up arrow icon
    7) Choose "UnsignedInt" and enter a value. 1 for red, 2 for blue, 3 for green
    8) Press "Write" and the LED should change accordingly