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
    const soundFactory = new NumberFactory(SOUND_THRESH_RANGE_LOW, SOUND_THRESH_RANGE_HI, SOUND_THRESH_INCREMENT, "$1$ dB");
    var soundDefault;

    function initialize() {
        soundDefault = soundFactory.getIndex(SOUND_THRESHOLD);
        Picker.initialize({:title=>soundTitle, :pattern=>[soundFactory], :defaults=>[soundDefault]});
    }
}

class TempMinPicker extends WatchUi.Picker {
    const tempMinTitle = new WatchUi.Text({:text=>"Temp Min", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    var tempMinFactory;
    var tempMinDefault;

    function initialize(){
        if(TEMP_MAX_THRESHOLD == null){
            tempMinFactory = new NumberFactory(
                TEMP_THRESH_RANGE_LOW,
                TEMP_THRESH_RANGE_HI,
                TEMP_THRESH_INCREMENT,
                "$1$ °C"
            );
        }
        else{
            tempMinFactory = new NumberFactory(
                TEMP_THRESH_RANGE_LOW,
                TEMP_MAX_THRESHOLD - TEMP_THRESH_INCREMENT,
                TEMP_THRESH_INCREMENT,
                "$1$ °C"
            );
        }
        tempMinDefault = tempMinFactory.getIndex(TEMP_MIN_THRESHOLD);
        Picker.initialize({:title=>tempMinTitle, :pattern=>[tempMinFactory], :defaults=>[tempMinDefault]});
    }
}

class TempMaxPicker extends WatchUi.Picker {
    const tempMaxTitle = new WatchUi.Text({:text=>"Temp Max", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    var tempMaxFactory;
    var tempMaxDefault;

    function initialize(){
        if(TEMP_MIN_THRESHOLD == null){
            tempMaxFactory = new NumberFactory(
                TEMP_THRESH_RANGE_LOW,
                TEMP_THRESH_RANGE_HI,
                TEMP_THRESH_INCREMENT,
                "$1$ °C"
            );
        }
        else{
            tempMaxFactory = new NumberFactory(
                TEMP_MIN_THRESHOLD + TEMP_THRESH_INCREMENT,
                TEMP_THRESH_RANGE_HI,
                TEMP_THRESH_INCREMENT,
                "$1$ °C"
            );
        }
        tempMaxDefault = tempMaxFactory.getIndex(TEMP_MAX_THRESHOLD);
        Picker.initialize({:title=>tempMaxTitle, :pattern=>[tempMaxFactory], :defaults=>[tempMaxDefault]});
    }
}
