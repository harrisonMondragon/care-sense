// This file is heavily inspired by:
// https://github.com/garmin/connectiq-apps/blob/eb0497a0377bbcb9495749c4071e872f67ba81e3/device-apps/bluetooth-mesh-sample/source/NumberFactory.mc

using Toybox.Graphics;
using Toybox.WatchUi;

class NumberFactory extends WatchUi.PickerFactory {
    hidden var mStart;
    hidden var mStop;
    hidden var mIncrement;
    hidden var mFormat;

    function getIndex(value) {
        var index = (value / mIncrement) - mStart;
        return index;
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

        return new WatchUi.Text({
            :text=>Lang.format(mFormat, [value]),
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_SMALL,
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    function getValue(index) {
        return mStart + (index * mIncrement);
    }

    function getSize() {
        return ( mStop - mStart ) / mIncrement + 1;
    }

}