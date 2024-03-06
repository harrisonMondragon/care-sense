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
