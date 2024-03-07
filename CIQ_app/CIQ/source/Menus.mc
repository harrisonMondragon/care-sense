import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;


// ------------------------------- DELEGATES -------------------------------

// Settings menu to choose what threshold to alter
class SettingsMenuInputDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        // Sound picker
        if (item == :sound) {
            var title = new WatchUi.Text({:text=>"Threshold", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
            var factory = new NumberFactory(5, 200, 5, "$1$ dB");
            var pickerDefault = factory.getIndex(SOUND_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
            WatchUi.pushView(picker, new SoundPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
        // Temp picker
        else if (item == :temp) {
            var title = new WatchUi.Text({:text=>"Threshold", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
            var factory = new NumberFactory(-20, 40, 1, "$1$ °C");
            var pickerDefault = factory.getIndex(TEMP_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
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
        System.println("Sound threshold value is: " + SOUND_THRESHOLD);
        WatchUi.pushView(new ThresholdChangeConfirmation(), new ThresholdChangeConfirmationDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }
}

// Change TEMP_THRESHOLD using temp picker
class TempPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values) {
        TEMP_THRESHOLD = values[0];
        System.println("Temp threshold value is: " + TEMP_THRESHOLD);
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
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop to HomeDisplay
        }
        return true;
    }
}
