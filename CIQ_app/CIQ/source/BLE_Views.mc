import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;

using Toybox.BluetoothLowEnergy as BLE;

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

        dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Setting up\nconnection...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}
}
