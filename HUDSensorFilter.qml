import QtQuick 2.5

QtObject {
    property var values: []
    property real sum: 0
    property real size: 1
    property bool enabled: size > 1
    property bool isAzimuthFilter: false
    property real criticalAngularRange: 30

    onSizeChanged: {
        reset(sum / values.length);
    }

    function update(value) {
        if (!enabled) {
            return value;
        }

        if (values.length == size) {
            sum -= values.shift();
        }

        if (!isAzimuthFilter) {

            sum += value;

            values.push(value);

            return sum / values.length;
        }

        // prevent jumps in angular data if crossing the 360 - 0 boundary
        var adjustedValue = values[values.length-1] - value > 360 - criticalAngularRange
                ? value + 360
                : value - values[values.length-1] > 360 - criticalAngularRange
                  ? value - 360
                  : value;

        sum += adjustedValue;

        values.push(adjustedValue);

        // correct stored values so that they stay within an acceptable range, do this
        // only once we are outside of the critical region
        if (adjustedValue > 360 + criticalAngularRange + 90) {
            for (var i=0; i<values.length; i++) {
                values[i] -= 360;
            }
            sum -= values.length * 360;
        } else if (adjustedValue < - criticalAngularRange - 90) {
            for (var j=0; j<values.length; j++) {
                values[j] += 360;
            }
            sum += values.length * 360;
        }

        return (sum / values.length + 360) % 360;
    }

    function reset(value) {
        if (enabled && value) {
            values = [];
            for (var i = 0; i < size; i++) {
                values[i] = value;
            }
            sum = size * value;
        }
    }
}
