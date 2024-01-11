import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;

using Toybox.BluetoothLowEnergy as BLE;

class Delegate extends BLE.BleDelegate {
    // Callback class for BLE functions and state changes
    var _scanResults = [null];
    var MAX_RESULTS = 10;
    var idx = 0;

    function initialize() {
        BleDelegate.initialize();
        registerProfiles();
    }

    function onScanResults(scanResults) {
        for (var result = scanResults.next(); result != null; result = scanResults.next()) {
            if (result instanceof BLE.ScanResult && result.getDeviceName() != null && _scanResults.indexOf(result) == -1) {
                _scanResults =_scanResults.add(result);
            }
        }
        // for (var result = scanResults.next(); result != null; result = scanResults.next()) {
        //     if (result instanceof BLE.ScanResult && result.getDeviceName() != null) {
        //         var iter = result.getServiceUuids();
        //         for (var uuid = iter.next(); uuid != null; uuid = iter.next()) {
        //             if (uuid.equals(BLE.stringToUuid("19b10000-e8f2-537e-4f6c-d104768a1214"))) {
        //                 _scanResults.add(result);
        //             }
        //         }
        //     }
        // }
    }

    function getScanResults() {
        return _scanResults.slice(1, null);
    }

    function registerProfiles() {
       var profile = {                                                  // Set the Profile
           :uuid => BLE.stringToUuid("19b10000-e8f2-537e-4f6c-d104768a1214"),
           :characteristics => [ {                                      // Define the characteristics
                   :uuid => BLE.stringToUuid("19b10001-e8f2-537e-4f6c-d104768a1214"),     // UUID of the first characteristic
                   :descriptors => [                                    // Descriptors of the characteristic
                       BLE.cccdUuid()] },
                       ]
       };

       // Make the registerProfile call
       BLE.registerProfile( profile );
  }
}


class BleScanner extends WatchUi.View {
    const SCAN_DELAY = 5;
    // var scanStartTime;
    // var scanEndTime;
    var x, y;
    var timer = new Timer.Timer();

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        x = dc.getWidth();
        y = dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        BLE.setScanState(BLE.SCAN_STATE_SCANNING);
        timer.start(method(:scanEnd), 5000, false);
        // scanStartTime = Time.now();
        // scanEndTime = scanStartTime.add(new Time.Duration(SCAN_DELAY));
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Scanning...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function scanEnd() {
        WatchUi.pushView(new BleResults(), null, WatchUi.SLIDE_IMMEDIATE);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}


class BleResults extends WatchUi.View {
    // Temporary class to for scanning purposes.
    var x, y;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        x = dc.getWidth();
        y = dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Done", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        BLE.setScanState(BLE.SCAN_STATE_OFF);
        // showScanMenu(dc);
        var scanResults = BLE_DELEGATE.getScanResults();
        dc.drawText(x / 2, y / 2 - 125, Graphics.FONT_MEDIUM, Lang.format("Scanned $1$\ndevice(s)", [scanResults.size()]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        for (var i = 0; i < scanResults.size(); i++) {
            dc.drawText(x / 2, 200 + (50 * i), Graphics.FONT_SMALL, scanResults[i].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}