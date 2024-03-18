// This file is heavily inspired by:
// https://github.com/garmin/connectiq-apps/blob/eb0497a0377bbcb9495749c4071e872f67ba81e3/device-apps/bluetooth-mesh-sample/source/NumberFactory.mc
// To create a PickerFactory for numbers based on a range and an increment amount

using Toybox.Graphics;
using Toybox.WatchUi;

class NumberFactory extends WatchUi.PickerFactory {
    hidden var mStart;
    hidden var mStop;
    hidden var mIncrement;
    hidden var mFormat;

    function getIndex(value) {
        // OFF case
        if (value == null){
            return (getSize() - 1);
        }
        // Normal case
        else {
            return ((value - mStart) / mIncrement);
        }
    }

    function initialize(start, stop, increment, format) {
        PickerFactory.initialize();
        mStart = start;
        mStop = stop;
        mIncrement = increment;
        mFormat = format;
    }

    function getDrawable(index, selected) {
        var value = getValue(index);

        // Deal with OFF
        var pickerText;
        if (value == null){
            pickerText = "OFF";
        } else {
            pickerText = Lang.format(mFormat, [value]);
        }

        return new WatchUi.Text({
            :text=>pickerText,
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SMALL,
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    function getValue(index) {
        // OFF case
        if (index == getSize() - 1){
            return null;
        }
        // Normal case
        else {
            return mStart + (index * mIncrement);
        }
    }

    function getSize() {
        // Add an extra index for OFF
        return ( mStop - mStart ) / mIncrement + 2;
    }

}