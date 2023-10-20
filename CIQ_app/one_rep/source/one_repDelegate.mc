import Toybox.Lang;
import Toybox.WatchUi;

class one_repDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new one_repMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}