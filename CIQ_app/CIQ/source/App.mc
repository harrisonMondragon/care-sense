import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as BLE;

// ------------------------------ GLOBALS ------------------------------
// Current Values
var SOUND_LEVEL = 0;
var TEMP_VAL = 0;
var SUBSCRIPTION_COUNT = 0;
var SETTINGS_AVAILABLE = false;

// Default Thresholds
var SOUND_THRESHOLD = 80; // max sound threshold in dB
var TEMP_MIN_THRESHOLD = 20; // min temperature threshold in ˚C
var TEMP_MAX_THRESHOLD = 35; // max temperature threshold in ˚C

// Threshold Ranges
var SOUND_THRESH_RANGE_LOW = 5; // Lowest available sound threshold in dB
var SOUND_THRESH_RANGE_HI = 200; // Highest available sound threshold in dB
var TEMP_THRESH_RANGE_LOW = -20; // Lowest available temp threshold in ˚C
var TEMP_THRESH_RANGE_HI = 40; // Highest available temp threshold in ˚C

// Threshold Picker Increments
var SOUND_THRESH_INCREMENT = 5; // Sound threshold increment for the picker in dB
var TEMP_THRESH_INCREMENT = 1; // Temp threshold increment for the picker in ˚C

// Enum of back pickers for threshold change confirmation page
enum BACK_PICKERS {
    SOUND_PICKER,
    TEMP_MIN_PICKER,
    TEMP_MAX_PICKER,
}

// Delays
var NOTIFICATION_DELAY = 15000; // notification delay in ms
var VIBE_DURATION = 2000; // vibration duration in ms

// Delegates
var BLE_DELEGATE;

// ------------------------------ CLASSES ------------------------------
class CIQApp extends Application.AppBase {

    private var _view;

    function initialize() {
        AppBase.initialize();
        _view = new BLEScanner();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // set up/check BLE connection here
        BLE_DELEGATE = new Delegate();
        BLE.setDelegate(BLE_DELEGATE);
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