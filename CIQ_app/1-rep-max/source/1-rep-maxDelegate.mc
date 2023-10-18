import Toybox.Lang;
import Toybox.WatchUi;

class 1-rep-maxDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new 1-rep-maxMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}