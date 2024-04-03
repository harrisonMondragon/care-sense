import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;

class EnvNotification extends WatchUi.View {
    var x, y;
    var timer = new Timer.Timer(); // timer for notification timeout
    var NOTIFICATION_DELAY = 15000;
    var label_x;
    var value_x;
    var vibed;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // Load screen height and width as dynamic resources
        x = dc.getWidth();
        y = dc.getHeight();

        label_x = x / 4;
        value_x = x / 2 + 40;
    }

    function onShow() as Void {
        SETTINGS_AVAILABLE = true;

        // Start timer here
        timer.start(method(:notificationDone), NOTIFICATION_DELAY, false); // start the timer
        vibed = false;
    }

    // Update the view every time a new BLE value comes in (see CIQBLE.mc:onCharacteristicChanged)
    function onUpdate(dc as Dc) as Void {

        // Vibrate and restart timer if we haven't vibrated yet
        if (SOUND_THRESHOLD != null && vibed == false) {
            if(SOUND_VAL > SOUND_THRESHOLD) {
                Attention.vibrate([new Attention.VibeProfile(100, VIBE_DURATION)]);
                timer.stop();
                timer.start(method(:notificationDone), NOTIFICATION_DELAY, false);
                vibed = true;
            }
        }
        if (TEMP_MIN_THRESHOLD != null && vibed == false) {
            if (TEMP_VAL < TEMP_MIN_THRESHOLD){
                Attention.vibrate([new Attention.VibeProfile(100, VIBE_DURATION)]);
                timer.stop();
                timer.start(method(:notificationDone), NOTIFICATION_DELAY, false);
                vibed = true;
            }
        }
        if (TEMP_MAX_THRESHOLD != null && vibed == false) {
            if(TEMP_VAL > TEMP_MAX_THRESHOLD) {
                Attention.vibrate([new Attention.VibeProfile(100, VIBE_DURATION)]);
                timer.stop();
                timer.start(method(:notificationDone), NOTIFICATION_DELAY, false);
                vibed = true;
            }
        }

        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2 - 110, Graphics.FONT_MEDIUM, "Environment\nwarning:", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(label_x, y / 2 - 20, Graphics.FONT_SMALL, "Sound:", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Display sound value in the correct text color
        if (SOUND_THRESHOLD != null) {
            if (SOUND_VAL >= SOUND_THRESHOLD) { // set color based on thresholds
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(value_x, y / 2 - 20, Graphics.FONT_SMALL, Lang.format("$1$ dB", [SOUND_VAL]), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Display current sound threshold if it is enabled
        if (SOUND_THRESHOLD != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(label_x, y / 2 + 20, Graphics.FONT_XTINY, "Max Sound:", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(value_x, y / 2 + 20, Graphics.FONT_XTINY, Lang.format("$1$ dB", [SOUND_THRESHOLD]), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(label_x, y / 2 + 70, Graphics.FONT_SMALL, "Temp:", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Display temp value in the correct text color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (TEMP_MAX_THRESHOLD != null) {
            if (TEMP_VAL >= TEMP_MAX_THRESHOLD) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
        }
        if (TEMP_MIN_THRESHOLD != null) {
            if (TEMP_VAL <= TEMP_MIN_THRESHOLD) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
        }
        dc.drawText(value_x, y / 2 + 70, Graphics.FONT_SMALL, Lang.format("$1$ °C", [TEMP_VAL.format("%.1f")]), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Display current temp thresholds if they are enabled
        if (TEMP_MIN_THRESHOLD != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(label_x, y / 2 + 110, Graphics.FONT_XTINY, "Min Temp:", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(value_x, y / 2 + 110, Graphics.FONT_XTINY, Lang.format("$1$ °C", [TEMP_MIN_THRESHOLD]), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        if (TEMP_MAX_THRESHOLD != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(label_x, y / 2 + 140, Graphics.FONT_XTINY, "Max Temp:", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(value_x, y / 2 + 140, Graphics.FONT_XTINY, Lang.format("$1$ °C", [TEMP_MAX_THRESHOLD]), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function onHide() as Void {
        timer.stop();
    }


    function notificationDone() {
        // notification has timed out and returning to home page.
        WatchUi.switchToView(new HomeDisplay(), new SensoryBehaviorDelegate(null, null), WatchUi.SLIDE_IMMEDIATE);
    }

}