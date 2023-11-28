import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class CIQApp extends Application.AppBase {

    private var _view;

    function initialize() {
        AppBase.initialize();
        _view = new CIQDisplay();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // set up/check BLE connection here
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ _view ] as Array<Views or InputDelegates>; // use home view var
    }

}

function getApp() as CIQApp {
    return Application.getApp() as CIQApp;
}