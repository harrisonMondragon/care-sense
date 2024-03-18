using Toybox.BluetoothLowEnergy as BLE;

class Sub2NotifQueue {
    // Queue for managing notification or indication subscriptions
    var queue = [];

    function initialize() {}

    function add(char) {
        if (char != null) {
            queue.add(char);
        }
    }

    function run() {
        if (queue.size() != 0) {
            var char = queue[0]; // extract characteristic
            var cccd = char.getDescriptor(BLE.cccdUuid()); // grab cccd
            cccd.requestWrite([0x01, 0x00]b); // write to descriptor

            queue = queue.slice(1, queue.size()); // remove the front element
        }
    }

    function clear() {
        queue = [];
    }
}