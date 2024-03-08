import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;

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
        if (swipeEvent.getDirection() == SWIPE_UP && SETTINGS_AVAILABLE == true){
            var menu = new WatchUi.Menu();
            menu.setTitle("Settings");
            menu.addItem("Sound", :sound);
            menu.addItem("Temp Min", :tempMin);
            menu.addItem("Temp Max", :tempMax);
            WatchUi.pushView(menu, new SettingsMenuInputDelegate(), WatchUi.SLIDE_UP);
        }
        return true;
    }
}

class ThresholdChangeConfirmationDelegate extends BehaviorDelegate {

    protected var back_picker; // picker to return to on back

    function initialize(_back_picker as BACK_PICKERS or Number) {
        back_picker = _back_picker;
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

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop to Picker
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop to Menu

        switch(back_picker) {
            case SOUND_PICKER:
                WatchUi.pushView(new SoundPicker(), new SoundPickerDelegate(), WatchUi.SLIDE_RIGHT);
                return true;
            case TEMP_MIN_PICKER:
                WatchUi.pushView(new TempMinPicker(), new TempMinPickerDelegate(), WatchUi.SLIDE_RIGHT);
                return true;
            case TEMP_MAX_PICKER:
                WatchUi.pushView(new TempMaxPicker(), new TempMaxPickerDelegate(), WatchUi.SLIDE_RIGHT);
                return true;
            default:
                return true;

        }
    }
}
