import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;

using Toybox.BluetoothLowEnergy as BLE;

// ------------------------------ GLOBALS ------------------------------
var SOUND_LEVEL = 0;

// ----------------------------- DELEGATES -----------------------------
class Delegate extends BLE.BleDelegate {
    // Callback class for BLE functions and state changes
    // Delegate initialized in CIQAPP.mc
    var sensorScanResult = null;

    // Sensor UUIDs
    public const SERVICE_UUID = BluetoothLowEnergy.stringToUuid("5d390f04-f945-4b02-9e4a-307f6a53b492");
    const CHAR_UUID = BLE.stringToUuid("d7df8570-d653-4ff9-a473-0352de9d0e7c");

    // Device connection info
    var device;

    function initialize() {
        BleDelegate.initialize();
        registerProfiles(); // register custom profiles
    }

    function onScanResults(scanResults) {
        // Within scanning time period, check each scan result for specified
        // sensor information (hard coded UUID for MVP) and connect.
        for (var result = scanResults.next(); result != null; result = scanResults.next()) {
            if (result instanceof BLE.ScanResult) {
                var iter = result.getServiceUuids();
                for (var uuid = iter.next(); uuid != null; uuid = iter.next()) {
                    if (uuid.equals(SERVICE_UUID)) {
                        sensorScanResult = result;
                    }
                }
            }
        }
    }

    function onConnectedStateChanged(device, state) {
        if (state == BLE.CONNECTION_STATE_CONNECTED) {
            System.println("Connected to " + device.getName());
            self.device = device;
            // sign up for notifications
            var descriptor = device.getService(SERVICE_UUID).getCharacteristic(CHAR_UUID).getDescriptor(BLE.cccdUuid());
            descriptor.requestWrite([0x01, 0x00]b);
            WatchUi.switchToView(new Connecting(), new SensoryBehaviorDelegate(new BLEScanner(), null), WatchUi.SLIDE_IMMEDIATE);
            System.println("View switched.");
        } else {
            self.device = null;
            WatchUi.switchToView(new SensorDisconnected(), new SensoryBehaviorDelegate(new BLEScanner(), null), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function onDescriptorWrite(descriptor, status) {
        if (status == BLE.STATUS_WRITE_FAIL) {
            System.println("Subscribed to notifications failed.");
        } else if (status == BLE.STATUS_SUCCESS) {
            System.println("Subscribed to notifications.");
            WatchUi.switchToView(new SoundDisplay(), new SensoryBehaviorDelegate(null, null), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function onCharacteristicChanged(char, val) {
        System.println("Char changed to " + val);
        SOUND_LEVEL = val[0]; // set sound levels to latest value
        WatchUi.requestUpdate(); // update what ever watch face is displayed
    }

    function getScanResult() {
        return sensorScanResult;
    }

    function connect () {
        BLE.setScanState(BLE.SCAN_STATE_OFF);
        BLE.pairDevice(sensorScanResult);
    }

    function registerProfiles() {
       var profile = {                     // Set the Profile
           :uuid => SERVICE_UUID,
           :characteristics => [ {         // Define the characteristics
                   :uuid => CHAR_UUID,     // UUID of the first characteristic
                   :descriptors => [       // Descriptors of the characteristic
                       BLE.cccdUuid()] },
                       ]
       };

       // Make the registerProfile call
       BLE.registerProfile( profile );
    }
}

// ------------------------------- VIEWS -------------------------------
class BLEScanner extends WatchUi.View {
    // View to display while scanning for sensor
    public const SCAN_DELAY = 5000; // delay in ms
    var x, y; // display size
    var timer = new Timer.Timer(); // used for timed callbacks

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {
        // Start scanning everytime the page is shown and begin scan delay timer
        BLE.setScanState(BLE.SCAN_STATE_SCANNING);
        timer.start(method(:scanEnd), SCAN_DELAY, false);
    }

    // Update the view onShow or as WatchUi.requestUpdate
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Scanning...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function scanEnd() {
        var result = BLE_DELEGATE.getScanResult();
        if (result == null) {
            WatchUi.switchToView(new SensorNotFound(), new SensoryBehaviorDelegate(new BLEScanner(), null), WatchUi.SLIDE_IMMEDIATE);
        } else {
            BLE_DELEGATE.connect();
        }
    }

    function onHide() as Void {
        // Turn off BLE scanning when the page dissapears
        BLE.setScanState(BLE.SCAN_STATE_OFF);
    }
}


class SensorNotFound extends WatchUi.View {
    // View to display error message if the sensor matching DEV_NAME and UUID
    // does not exist.
    var x, y;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {
        BLE.setScanState(BLE.SCAN_STATE_OFF); // stop scanning to preserve resources
    }

    // Update the view onShow or as WatchUi.requestUpdate
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "No Sensor Found.", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}
}

class Connecting extends WatchUi.View {
    // View to show connection delay
    var x, y;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {
        BLE.setScanState(BLE.SCAN_STATE_OFF); // stop scanning to preserve resources
    }

    // Update the view onShow or as WatchUi.requestUpdate
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Connecting...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}
}