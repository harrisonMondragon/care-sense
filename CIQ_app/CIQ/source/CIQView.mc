import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;

// ------------------------------ GLOBALS ------------------------------
var SOUND_THRESHOLD = 80; // max sound threshold in dB
var NOTIFICATION_DELAY = 15000; // notification delay in ms
var VIBE_DURATION = 2000; // vibration duration in ms

// ----------------------------- DELEGATES -----------------------------
class SensoryBehaviorDelegate extends BehaviorDelegate {
    protected var back_page; // page to return to on back
    protected var back_back_page; // back page for that page

    function initialize(_page, _back_page) {
        back_page = _page;
        back_back_page = _back_page;
        BehaviorDelegate.initialize();
    }

    function onBack() {
        if (back_page != null) {
            WatchUi.switchToView(back_page, new SensoryBehaviorDelegate(back_back_page, null), WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }

    // Start settings sequence on swipe up
    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == SWIPE_UP){
            var menu = new WatchUi.Menu();
            menu.setTitle("Settings");
            menu.addItem("Sound", :sound);
            menu.addItem("Temperature", :temp);
            WatchUi.pushView(menu, new SettingsMenuInputDelegate(), WatchUi.SLIDE_UP);
        }
        return true;
    }
}

// Settings menu to choose what threshold to alter
class SettingsMenuInputDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        // Sound picker
        if (item == :sound) {
            var title = new WatchUi.Text({:text=>"Sound Threshold", :font=>Graphics.FONT_SMALL});
            var factory = new NumberFactory(30, 120, 5, "$1$ dB");
            var pickerDefault = factory.getIndex(SOUND_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
            WatchUi.pushView(picker, new SoundPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
        // Temp picker
        // TODO: Add the default when merged with dev/temp
        else if (item == :temp) {
            var title = new WatchUi.Text({:text=>"Temp Threshold", :font=>Graphics.FONT_SMALL});
            var factory = new NumberFactory(-20, 40, 1, "$1$ °C");
            // ----- var pickerDefault = factory.getIndex(TEMP_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory]});
            // ----- var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory] :defaults=>[pickerDefault]});
            WatchUi.pushView(picker, new TempPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
    }
}

// Change SOUND_THRESHOLD using sound picker
class SoundPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values) {
        SOUND_THRESHOLD = values[0];
        WatchUi.pushView(new ThresholdChangeConfirmation(), new ThresholdChangeConfirmationDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }
}

// Change TEMP_THRESHOLD using temp picker
// TODO: Make it actually change TEMP_THRESHOLD when merged with dev/temp
class TempPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values) {
        // ----- TEMP_THRESHOLD = values[0];
        WatchUi.pushView(new ThresholdChangeConfirmation(), new ThresholdChangeConfirmationDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }
}

// Get back to regular pages on threshold confirmation
class ThresholdChangeConfirmationDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == SWIPE_DOWN){
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop to Picker
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop to Menu
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop to SoundDisplay
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
            WatchUi.switchToView(new SoundNotification(), new SensoryBehaviorDelegate(new SoundDisplay(), null), WatchUi.SLIDE_IMMEDIATE);
        }

        // set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, x, y);

        // set foreground color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(x / 2, y / 2-30, Graphics.FONT_MEDIUM, "Current Environment\nSound Levels", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2+80, Graphics.FONT_MEDIUM, Lang.format("$1$ dB", [SOUND_LEVEL]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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

class SoundNotification extends WatchUi.View {
    var x, y;
    var timer = new Timer.Timer(); // timer for notification timeout

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
        // Vibrate the watch
        Attention.vibrate([new Attention.VibeProfile(100, VIBE_DURATION)]);

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

        dc.drawText(x / 2, y / 2 - 50, Graphics.FONT_MEDIUM, Lang.format("Environment\nsound has exceeded\n$1$ dB.", [SOUND_THRESHOLD]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2 + 80, Graphics.FONT_MEDIUM, "Current sound is", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // change font color
        if (SOUND_LEVEL >= SOUND_THRESHOLD) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(x / 2, y / 2 + 130, Graphics.FONT_MEDIUM, Lang.format("$1$ dB", [SOUND_LEVEL]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {
        timer.stop();
    }


    function notificationDone() {
        // notification has timed out and returning to home page.
        WatchUi.switchToView(new SoundDisplay(), new SensoryBehaviorDelegate(null, null), WatchUi.SLIDE_IMMEDIATE);
    }

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

        // TODO: Add temp confirmation too after dev/temp merged
        dc.drawText(x / 2, y / 2 - 125, Graphics.FONT_TINY, Lang.format(" Current sound\nthreshold: $1$ dB", [SOUND_THRESHOLD]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x / 2, y / 2 - 25, Graphics.FONT_TINY, Lang.format("Current temp\nthreshold: $1$ °C", [999]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // ----- dc.drawText(x / 2, y / 2 + 50, Graphics.FONT_SMALL, Lang.format("Current temp\nthreshold: $1$ °C", [TEMP_THRESHOLD]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x / 2, y / 2 + 125, Graphics.FONT_SMALL, "Swipe Down to\nGo Back", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}

}
