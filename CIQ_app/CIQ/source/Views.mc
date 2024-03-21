import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;

class HomeDisplay extends WatchUi.View {
    var x, y;
    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();
    }

    function onShow() as Void {
        SETTINGS_AVAILABLE = true;
    }

    // Update the view every time a new BLE value comes in (see CIQBLE.mc:onCharacteristicChanged)
    function onUpdate(dc as Dc) as Void {

        // Check thresholds against sensor readings
        if (SOUND_THRESHOLD != null){
            if (SOUND_VAL > SOUND_THRESHOLD) {
                WatchUi.switchToView(new EnvNotification(), new SensoryBehaviorDelegate(new HomeDisplay(), null), WatchUi.SLIDE_IMMEDIATE);
            }
        }
        if (TEMP_MIN_THRESHOLD != null){
            if (TEMP_VAL < TEMP_MIN_THRESHOLD) {
                WatchUi.switchToView(new EnvNotification(), new SensoryBehaviorDelegate(new HomeDisplay(), null), WatchUi.SLIDE_IMMEDIATE);
            }
        }
        if (TEMP_MAX_THRESHOLD != null){
            if (TEMP_VAL > TEMP_MAX_THRESHOLD) {
                WatchUi.switchToView(new EnvNotification(), new SensoryBehaviorDelegate(new HomeDisplay(), null), WatchUi.SLIDE_IMMEDIATE);
            }
        }

        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x / 2, y / 2-70, Graphics.FONT_MEDIUM, "Current Environment", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2+10, Graphics.FONT_MEDIUM, Lang.format("Sound: $1$ dB", [SOUND_VAL]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2+80, Graphics.FONT_MEDIUM, Lang.format("Temp: $1$ °C", [TEMP_VAL.format("%.1f")]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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

    function onShow() as Void {
        SETTINGS_AVAILABLE = false;
        // Vibrate the watch
        Attention.vibrate([new Attention.VibeProfile(100, VIBE_DURATION)]);
    }

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

class ThresholdChangeConfirmation extends WatchUi.View {
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

    function onUpdate(dc as Dc) as Void {
        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Confirmation messages
        var soundThreshString;
        var tempMinThreshString;
        var tempMaxThreshString;

        if (SOUND_THRESHOLD == null){
            soundThreshString = "OFF";
        } else {
            soundThreshString = Lang.format("$1$ dB", [SOUND_THRESHOLD]);
        }

        if (TEMP_MIN_THRESHOLD == null){
            tempMinThreshString = "OFF";
        } else {
            tempMinThreshString = Lang.format("$1$ °C", [TEMP_MIN_THRESHOLD]);
        }

        if (TEMP_MAX_THRESHOLD == null){
            tempMaxThreshString = "OFF";
        } else {
            tempMaxThreshString = Lang.format("$1$ °C", [TEMP_MAX_THRESHOLD]);
        }

        dc.drawText(x / 2, y / 2 - 125, Graphics.FONT_TINY, Lang.format("Current sound\nthreshold: $1$", [soundThreshString]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2, Graphics.FONT_TINY, Lang.format("Current temp thresholds:\nMin: $1$, Max: $2$", [tempMinThreshString, tempMaxThreshString]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x / 2, y / 2 + 125, Graphics.FONT_SMALL, "Swipe Down to\nGo Back", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}

}