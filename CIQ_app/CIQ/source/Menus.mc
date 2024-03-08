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
            var title = new WatchUi.Text({:text=>"Sound Max", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
            var factory = new NumberFactory(5, 200, 5, "$1$ dB");
            var pickerDefault = factory.getIndex(SOUND_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
            WatchUi.pushView(picker, new SoundPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
        // Temp max picker
        else if (item == :tempMax) {
            var title = new WatchUi.Text({:text=>"Temp Max", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
            var factory = new NumberFactory(TEMP_MIN_THRESHOLD, 40, 1, "$1$ °C");
            var pickerDefault = factory.getIndex(TEMP_MAX_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
            WatchUi.pushView(picker, new TempMaxPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
        // Temp min picker
        else if (item == :tempMin) {
            var title = new WatchUi.Text({:text=>"Temp Min", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
            var factory = new NumberFactory(-20, TEMP_MAX_THRESHOLD, 1, "$1$ °C");
            var pickerDefault = factory.getIndex(TEMP_MIN_THRESHOLD);
            var picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
            WatchUi.pushView(picker, new TempMinPickerDelegate(), WatchUi.SLIDE_LEFT);
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
        WatchUi.pushView(new ThresholdChangeConfirmation(), new ThresholdChangeConfirmationDelegate(SOUND_PICKER), WatchUi.SLIDE_LEFT);
        return true;
    }
}

// Change TEMP_MAX_THRESHOLD using temp picker
class TempMaxPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values) {
        TEMP_MAX_THRESHOLD = values[0];
        System.println("Temp max threshold value is: " + TEMP_MAX_THRESHOLD);
        WatchUi.pushView(new ThresholdChangeConfirmation(), new ThresholdChangeConfirmationDelegate(TEMP_MAX_PICKER), WatchUi.SLIDE_LEFT);
        return true;
    }
}

// Change TEMP_MIN_THRESHOLD using temp picker
class TempMinPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values) {
        TEMP_MIN_THRESHOLD = values[0];
        System.println("Temp min threshold value is: " + TEMP_MIN_THRESHOLD);
        WatchUi.pushView(new ThresholdChangeConfirmation(), new ThresholdChangeConfirmationDelegate(TEMP_MIN_PICKER), WatchUi.SLIDE_LEFT);
        return true;
    }
}
