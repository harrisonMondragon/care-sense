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
            menu.addItem("Temperature", :temp);
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

        var title;
        var factory;
        var pickerDefault;
        var picker;

        switch(back_picker) {
            case SOUND_PICKER:
                title = new WatchUi.Text({:text=>"Threshold", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
                factory = new NumberFactory(5, 200, 5, "$1$ dB");
                pickerDefault = factory.getIndex(SOUND_THRESHOLD);
                picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
                WatchUi.pushView(picker, new SoundPickerDelegate(), WatchUi.SLIDE_RIGHT);
                return true;
            case TEMP_PICKER:
                title = new WatchUi.Text({:text=>"Threshold", :font=>Graphics.FONT_SMALL, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
                factory = new NumberFactory(-20, 40, 1, "$1$ °C");
                pickerDefault = factory.getIndex(TEMP_THRESHOLD);
                picker = new WatchUi.Picker({:title=>title, :pattern=>[factory], :defaults=>[pickerDefault]});
                WatchUi.pushView(picker, new TempPickerDelegate(), WatchUi.SLIDE_RIGHT);
                return true;
            default:
                return true;
        }
    }
}
