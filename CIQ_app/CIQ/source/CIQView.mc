import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

// ------------------------------ GLOBALS ------------------------------
var SOUND_THRESHOLD = 80; // max sound threshold in dB

// ----------------------------- DELEGATES -----------------------------
class BackDelegate extends BehaviorDelegate {
    protected var back_page; // page to return to on back
    protected var back_back_page; // back page for that page

    function initialize(_page, _back_page) {
        back_page = _page;
        back_back_page = _back_page;
        BehaviorDelegate.initialize();
    }

    function onBack() {
        if (back_page != null) {
            WatchUi.switchToView(back_page, new BackDelegate(back_back_page, null), WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}

// ------------------------------- VIEWS -------------------------------
class SoundDisplay extends WatchUi.View {
    var x, y;
    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {}

    // Update the view every time a new BLE value comes in (see CIQBLE.mc:onCharacteristicChanged)
    function onUpdate(dc as Dc) as Void {
        if (SOUND_LEVEL > SOUND_THRESHOLD) {
            // verify the threshold
            WatchUi.switchToView(new SoundNotification(), new BackDelegate(new SoundDisplay(), null), WatchUi.SLIDE_IMMEDIATE);
        }

        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2-70, Graphics.FONT_LARGE, "Sound", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2+20, Graphics.FONT_MEDIUM, Lang.format("$1$ dB", [SOUND_LEVEL]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}

}

class SensorDisconnected extends WatchUi.View {
    // Called when the sensor disconnects (See CIQBLE.mc:onConnectedStateChanged)
    var x, y;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {}

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2-50, Graphics.FONT_MEDIUM, "Sensor has\ndisconnected.", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2 + 70, Graphics.FONT_SYSTEM_SMALL, "Check if your charge has\nwandered off.", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}

}

class SoundNotification extends WatchUi.View {
    var x, y;
    var timer = new Timer.Timer(); // timer for notification timeout
    var NOTIFICATION_DELAY = 15000;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // Load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {
        // Start the timer timeout method
        timer.start(method(:notificationDone), NOTIFICATION_DELAY, false);
    }

    // Update the view every time a new BLE value comes in (see CIQBLE.mc:onCharacteristicChanged)
    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2 - 50, Graphics.FONT_MEDIUM, "Environment\nsound has exceeded\nset threshold.", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // change font color
        if (SOUND_LEVEL >= SOUND_THRESHOLD) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(x / 2, y / 2 + 100, Graphics.FONT_MEDIUM, Lang.format("$1$ dB", [SOUND_LEVEL]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {
        // TODO: Verify that stop works on non-repeat timers or how to prevent a
        // timer from triggering. Maybe check view to make sure it is right
        // before switching.
        timer.stop();
    }


    function notificationDone() {
        // notification has timed out and returning to home page.
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}
