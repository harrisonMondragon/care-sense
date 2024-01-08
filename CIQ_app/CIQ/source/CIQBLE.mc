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
        // _scanResults = new[MAX_RESULTS];
    }

    function onScanResults(scanResults) {
        for (var result = scanResults.next(); result != null; result = scanResults.next()) {
            if (result instanceof BLE.ScanResult && result.getDeviceName() != null) {
                _scanResults =_scanResults.add(result);
            }
        }
    }

    function getScanResults() {
        return _scanResults.slice(1, null);
    }
}


class BleScanner extends WatchUi.View {
    const SCAN_DELAY = 5;
    var scanStartTime;
    var scanEndTime;
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
        BLE.setScanState(BLE.SCAN_STATE_SCANNING);
        scanStartTime = Time.now();
        scanEndTime = scanStartTime.add(new Time.Duration(SCAN_DELAY));
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);


        if (scanEndTime.lessThan(Time.now())) {
            // dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Done", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            BLE.setScanState(BLE.SCAN_STATE_OFF);
            // showScanMenu(dc);
            var scanResults = BLE_DELEGATE.getScanResults();
            if (scanResults != null) {
                var spacing = 50;
                // dc.drawText(x / 2, y / 2 - 50, Graphics.FONT_MEDIUM, Lang.format("Scanned $1$\ndevices", [scanResults.size()]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(x / 2, spacing * 2, Graphics.FONT_SMALL, scanResults[0].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(x / 2, spacing * 3, Graphics.FONT_SMALL, scanResults[1].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(x / 2, spacing * 4, Graphics.FONT_SMALL, scanResults[2].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(x / 2, spacing * 5, Graphics.FONT_SMALL, scanResults[3].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(x / 2, spacing * 6, Graphics.FONT_SMALL, scanResults[4].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                // for(var i = 0; i < scanResults.size(); i++) {
                //     dc.drawText(x / 2, (i * 5), Graphics.FONT_SMALL, scanResults[i].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                // }
            } else {
                dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "No Results", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else {
            dc.drawText(x / 2, y / 2, Graphics.FONT_MEDIUM, "Scanning...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function showScanMenu(dc) {
        var scanResults = BLE_DELEGATE.getScanResults();
        if (scanResults != null) {
            for(var i = 0; i < scanResults.size(); i++) {
                dc.drawText(x / 2, y + i * 20, Graphics.FONT_SMALL, scanResults[i].getDeviceName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else {
            // use Confirmation and Confirmation Delegate to scan again
        }
    }
}
