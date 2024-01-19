# CIQ Test Plan
Live document for the active CIQ test plan including the MVP test plan, a test plan for extra features, and the system test plan (copied from official document).

[MVP Test Plan](#mvp-test-plan)

## MVP Test Plan
**Features Tested**
- Basic CIQ application displays
    - the current sensor readings for sounds
    - notifies the wearer if sound goes above the threshold
    - notify user on a connection drop out
- CIQ Sensor data access allows access to the data sent over BLE and updates the current sensor readings
- BLE communication
    - the device must be able to connect to the sensor and receive data on a 1 second update
    - disconnections must attempt an auto reconnect

### Tests
**Connection Testing**

Outcome: *pass/fail*
1. Set the watch to look for the arduino and set the arduino to advertising.
    - Watch should display "Scanning..."
2. Connect to sensor
    - Connection automatically occurs and the watch changes to "Connecting..." while the arduino logs indicate a connection was formed
3. Return to home and observe changing values. Change the noise levels in the environement to ensure changing values.
    - The watch should automatically return to the home page where sound values are updated every second.
4. Hit reset on the Arduino
    - See the watch flash to "Sensor has diconnected. Check if your charge has wandered off." before returning to the home page.
5. Walk away from the Arduino until disconnection occurs, return in range
    - See the watch switch to sensor disconnected message (step 4) when out of range and the Arduino returns to advertising. Then see the watch repeat connection stages and the arduino mimic the changes.
6. Unplug the arduino and sit for 1 minute
    - See permanent disconnection message and no return to home page.

**Notification Testing**

Outcome: *pass/fail*
1. Connect to the arduino as listed in *Connection Testing*.
    - Watch goes through the connecting pages and sits on the sound display screen
2. Create a loud noise near the arduino to trigger noise levels over 80 dB.
    - Watch changes to "Environment sound has exceeded set threshold." with the current db value in red.
3. Let the environment around the arduino go quiet again
    - Watch displayed decibal levels turn white below threshold.
4. Make a loud noise again.
    - See color of dB turn red
5. Wait for notification to dissapear.
    - Wait 15 seconds since the notification was initially triggered before it automatically returns to the home page.
6. Trigger a loud noise to get the notification page, then hit the back button
    - Notification will appear and back button will dismiss the notification early, returning to the home page.



## Additional Features Test Plan
**Features**
- On disconnection, the device attempts to reconnect or allows users to return to the scanning page
- Thresholds can be updated and the code adjust for it (optionally, the new threshold is permanent - maybe another feature)
- Going back on any page returns to a logical previous page

### Tests
