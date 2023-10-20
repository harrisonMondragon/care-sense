import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class one_repApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new one_repView(), new one_repDelegate() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as one_repApp {
    return Application.getApp() as one_repApp;
}