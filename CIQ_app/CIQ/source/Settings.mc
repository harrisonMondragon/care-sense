import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;


// ------------------------------- DELEGATES -------------------------------

class SettingsMenuInputDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :sound) {
            WatchUi.pushView(new SoundPicker(), new SoundPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
        else if (item == :tempMin) {
            WatchUi.pushView(new TempMinPicker(), new TempMinPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
        else if (item == :tempMax) {
            WatchUi.pushView(new TempMaxPicker(), new TempMaxPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
    }
}

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


// ------------------------------- PICKERS -------------------------------

class SoundPicker extends WatchUi.Picker {
    const soundTitle = new WatchUi.Text({:text=>"Sound Max", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});

    function initialize() {
        var factory = new NumberFactory(5, 200, 5, "$1$ dB");
        var pickerDefault = factory.getIndex(SOUND_THRESHOLD);
        Picker.initialize({:title=>soundTitle, :pattern=>[factory], :defaults=>[pickerDefault]});
    }
}

class TempMinPicker extends WatchUi.Picker {
    const tempMinTitle = new WatchUi.Text({:text=>"Temp Min", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});

    function initialize(){
        var factory = new NumberFactory(-20, TEMP_MAX_THRESHOLD, 1, "$1$ °C");
        var pickerDefault = factory.getIndex(TEMP_MIN_THRESHOLD);
        Picker.initialize({:title=>tempMinTitle, :pattern=>[factory], :defaults=>[pickerDefault]});
    }
}

class TempMaxPicker extends WatchUi.Picker {
    const tempMaxTitle = new WatchUi.Text({:text=>"Temp Max", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});

    function initialize(){
        var factory = new NumberFactory(TEMP_MIN_THRESHOLD, 40, 1, "$1$ °C");
        var pickerDefault = factory.getIndex(TEMP_MAX_THRESHOLD);
        Picker.initialize({:title=>tempMaxTitle, :pattern=>[factory], :defaults=>[pickerDefault]});
    }
}
