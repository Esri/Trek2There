import QtQuick 2.5
import QtQuick.Window 2.2
import QtPositioning 5.3
import QtSensors 5.3

import ArcGIS.AppFramework 1.0

Item {
    id: sensors

    // XXX Temporary fix for issue 106: Windows sensor orientation differences
    readonly property bool isWindows: Qt.platform.os === "windows"
    readonly property var beyondVerticalIndicator:
        rotationSensor.active && rotationSensor.reading
        ? isWindows
        ? rotationSensor.reading.x
        : rotationSensor.reading.y
        : 0.0;

    readonly property int kFilterSizeThreshold: 5
    readonly property real kAngularVelocityThreshold: 5
    readonly property real kStationaryAngularVelocityThreshold: 2.5
    readonly property real kMaxRotationSensorCalibrationThreshold: 10
    readonly property real rotationSensorCalibrationLevel: calculateRotationSensorCalibration()

//    property alias positionSource: positionSource
    property alias compass: compass
    property alias tiltSensor: tiltSensor
    property alias rotationSensor: rotationSensor
    property alias orientationSensor: orientationSensor
    property alias gyroscope: gyroscope

    property alias azimuthFilter: azimuthFilter
    property alias pitchAngleFilter: pitchAngleFilter
    property alias rollAngleFilter: rollAngleFilter

    property bool hasCompass: false
    property bool hasTiltSensor: false
    property bool hasRotationSensor: false
    property bool hasGyroscope: false

    property bool hasPitchSensor: false
    property bool hasRollSensor: false
    property bool hasZRotationSensor: false
    property bool useRotationZAsAzimuth: false

    //--------------------------------------------------------------------------

    property real movementThreshold: 3

    // filtered sensor readings
    property real azimuthFromTrueNorth: useRotationZAsAzimuth
                                        ? normAngle(azimuthFromYawAngle + magneticDeclination)
                                        : normAngle(azimuthFromMagNorth + magneticDeclination)
    property real azimuthFromMagNorth: sensorAzimuth
    property real azimuthFromYawAngle: sensorYawAngle
    property real pitchAngle: sensorPitchAngle
    property real rollAngle: sensorRollAngle
    property real turnVelocity: sensorTurnVelocity

    // unfiltered sensor readings
    property real sensorAzimuth: 0
    property real sensorYawAngle: 0
    property real sensorPitchAngle: 0
    property real sensorRollAngle: 0
    property real sensorTurnVelocity: 0

    // raw sensor readings
//    property Position position
    property CompassReading compassReading
    property TiltReading tiltReading
    property RotationReading rotationReading
    property GyroscopeReading gyroscopeReading

    property var orientation: OrientationReading.TopUp
    property var lastOrientation: OrientationReading.TopUp
    property real lastCalibrationLevel: 0
    property real magneticDeclination: 0

    property real azimuthSamplingRate: 0
    property real attitudeSamplingRate: 0
    property int azimuthSamples: 0
    property int attitudeSamples: 0

    property int azimuthStationaryDelay: 0
    property int attitudeStationaryDelay: 0

    property int azimuthFilterType: 0 // 0=rounding 1=smoothing
    property int azimuthRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
    property int azimuthFilterLength: 10

    property int attitudeFilterType: 0 // 0=rounding 1=smoothing
    property int attitudeRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
    property int attitudeFilterLength: 10

    property bool reduceSmoothing: false
    property bool deviceTurning: false

//    signal sensorPositionChanged();

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        checkSensorAvailability();
    }

    //--------------------------------------------------------------------------

    onSensorAzimuthChanged: {
        azimuthSamples++;

        if (!gyroscope.active || deviceTurning || azimuthStationaryDelay >= 0) {
            if (azimuthFilterType == 0) {
                azimuthFromMagNorth = azimuthRounding > 0
                        ? Math.round(sensorAzimuth * azimuthRounding) / azimuthRounding
                        : sensorAzimuth;
            } else {
                azimuthFromMagNorth = azimuthFilter.update(sensorAzimuth);
                if (gyroscope.active && !deviceTurning && azimuthFilterType != 0) {
                    azimuthStationaryDelay--;
                }
            }
        }
    }

    onSensorYawAngleChanged: {
        if (!gyroscope.active || deviceTurning || azimuthStationaryDelay >= 0) {
            if (azimuthFilterType == 0) {
                azimuthFromYawAngle = azimuthRounding > 0
                        ? Math.round(sensorYawAngle * azimuthRounding) / azimuthRounding
                        : sensorYawAngle;
            } else {
                azimuthFromYawAngle = yawAngleFilter.update(sensorYawAngle);
            }
        }
    }

    onSensorPitchAngleChanged: {
        attitudeSamples++;

        if (!gyroscope.active || deviceTurning || attitudeStationaryDelay >= 0) {
            if (attitudeFilterType == 0) {
                pitchAngle = attitudeRounding > 0
                        ? Math.round(sensorPitchAngle * attitudeRounding) / attitudeRounding
                        : sensorPitchAngle;
            } else {
                pitchAngle = pitchAngleFilter.update(sensorPitchAngle);
                if (gyroscope.active && !deviceTurning && attitudeFilterType != 0) {
                    attitudeStationaryDelay--;
                }
            }
        }
    }

    onSensorRollAngleChanged: {
        if (!gyroscope.active || deviceTurning || attitudeStationaryDelay >= 0) {
            if (attitudeFilterType == 0) {
                rollAngle = attitudeRounding > 0
                        ? Math.round(sensorRollAngle * attitudeRounding) / attitudeRounding
                        : sensorRollAngle;
            } else {
                rollAngle = rollAngleFilter.update(sensorRollAngle);
            }
        }
    }

    onSensorTurnVelocityChanged: {
        turnVelocity = turnVelocityFilter.update(sensorTurnVelocity);
    }

    onTurnVelocityChanged: {
        if (!deviceTurning && turnVelocity >= kStationaryAngularVelocityThreshold) {
            deviceTurning = true;
            azimuthStationaryDelay = azimuthFilterType != 0 ? azimuthFilterLength : 0;
            attitudeStationaryDelay = attitudeFilterType != 0 ? attitudeFilterLength : 0;
        } else if (deviceTurning && turnVelocity < kStationaryAngularVelocityThreshold) {
            deviceTurning = false;
        }

        if (!reduceSmoothing && Math.abs(turnVelocity) >= kAngularVelocityThreshold) {
            reduceSmoothing = true;

            if (azimuthFilterType != 0) {
                azimuthFilter.size = kFilterSizeThreshold;
                yawAngleFilter.size = kFilterSizeThreshold;
            }

            if (attitudeFilterType != 0) {
                pitchAngleFilter.size = kFilterSizeThreshold;
                rollAngleFilter.size = kFilterSizeThreshold;
            }
        } else if (reduceSmoothing && Math.abs(turnVelocity) < kAngularVelocityThreshold) {
            reduceSmoothing = false;

            if (azimuthFilterType != 0) {
                azimuthFilter.size = azimuthFilterLength;
                yawAngleFilter.size = azimuthFilterLength;
            }

            if (attitudeFilterType != 0) {
                pitchAngleFilter.size = attitudeFilterLength;
                rollAngleFilter.size = attitudeFilterLength;
            }
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: azimuthTimer

        property real startTime:0
        property real currentTime:0

        interval: 1000
        running: compass.active || rotationSensor.active
        repeat: true

        onRunningChanged: {
            if (running) {
                startTime = (new Date).getTime()
            }
        }

        onTriggered: {
            currentTime = (new Date).getTime();
            azimuthSamplingRate = azimuthSamples / (currentTime - startTime) * 1000;
            startTime = currentTime;
            azimuthSamples = 0;
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: attitudeTimer

        property real startTime:0
        property real currentTime:0

        interval: 1000
        running: tiltSensor.active || rotationSensor.active
        repeat: true

        onRunningChanged: {
            if (running) {
                startTime = (new Date).getTime()
            }
        }

        onTriggered: {
            currentTime = (new Date).getTime();
            attitudeSamplingRate = attitudeSamples / (currentTime - startTime) * 1000;
            startTime = currentTime;
            attitudeSamples = 0;
        }
    }

    //--------------------------------------------------------------------------

    HUDSensorFilter{
        id: azimuthFilter

        size: azimuthFilterLength
        isAzimuthFilter: true
    }

    HUDSensorFilter{
        id: yawAngleFilter

        size: azimuthFilterLength
        isAzimuthFilter: true
    }

    HUDSensorFilter {
        id: pitchAngleFilter

        size: attitudeFilterLength
    }

    HUDSensorFilter {
        id: rollAngleFilter

        size: attitudeFilterLength
    }

    HUDSensorFilter {
        id: turnVelocityFilter

        size: kFilterSizeThreshold
    }

    //--------------------------------------------------------------------------

//    PositionSource {
//        id: positionSource

//        property date activatedTimestamp
//        property bool positionUpToDate

//        active: false

//        onActiveChanged: {
//            if (active) {
//                activatedTimestamp = new Date();
//                positionUpToDate = position.timestamp > activatedTimestamp;
//            } else {
//                positionUpToDate = false;
//            }
//        }

//        onPositionChanged: {
//            positionUpToDate = position.timestamp > activatedTimestamp;

//            if (position.latitudeValid && position.longitudeValid && positionUpToDate) {
//                sensors.position = position;
//                // #46, #101, #142 need to signal a change or position will not be updated
//                sensorPositionChanged();
//            }
//        }

//        function activate() {
//            console.log("Starting position source:", name);

//            AppFramework.environment.setValue("APPSTUDIO_POSITION_DESIRED_ACCURACY", "HIGHEST");
//            AppFramework.environment.setValue("APPSTUDIO_POSITION_ACTIVITY_MODE", "OTHERNAVIGATION");
//            AppFramework.environment.setValue("APPSTUDIO_POSITION_MOVEMENT_THRESHOLD", movementThreshold.toString());

//            start();
//        }
//    }

    //--------------------------------------------------------------------------

    Compass {
        id: compass

        active: false
        axesOrientationMode: Sensor.AutomaticOrientation

        onReadingChanged: {
            switch (orientation) {
            case OrientationReading.TopUp:
            case OrientationReading.TopDown:
            case OrientationReading.LeftUp:
            case OrientationReading.RightUp:
                setAzimuthFromMag(reading.azimuth, orientation);
                break;

            case OrientationReading.FaceUp:
            case OrientationReading.FaceDown:
                setAzimuthFromMag(reading.azimuth, lastOrientation);
                break;

            case OrientationReading.Undefined:
            default:
                switch (Screen.orientation) {
                case 1: // Portrait up
                    setAzimuthFromMag(reading.azimuth, OrientationReading.TopUp);
                    break;

                case 2: // Landscape up
                    setAzimuthFromMag(reading.azimuth, OrientationReading.RightUp);
                    break;

                case 4: // Portrait down
                    setAzimuthFromMag(reading.azimuth, OrientationReading.TopDown);
                    break;

                case 8: // Landscape down
                    setAzimuthFromMag(reading.azimuth, OrientationReading.LeftUp);
                    break;
                }
                break;
            }

            compassReading = reading;
        }
    }

    //--------------------------------------------------------------------------

    TiltSensor {
        id: tiltSensor

        active: false
        axesOrientationMode: Sensor.FixedOrientation

        onReadingChanged: {
            switch (orientation) {
            case OrientationReading.TopUp:
            case OrientationReading.TopDown:
            case OrientationReading.LeftUp:
            case OrientationReading.RightUp:
                setPitchAndRoll(reading.xRotation, reading.yRotation, orientation);
                break;

            case OrientationReading.FaceUp:
            case OrientationReading.FaceDown:
                setPitchAndRoll(reading.xRotation, reading.yRotation, lastOrientation);
                break;

            case OrientationReading.Undefined:
            default:
                switch (Screen.orientation) {
                case 1: // Portrait up
                    setPitchAndRoll(reading.xRotation, reading.yRotation, OrientationReading.TopUp);
                    break;

                case 2: // Landscape up
                    setPitchAndRoll(reading.xRotation, reading.yRotation, OrientationReading.RightUp);
                    break;

                case 4: // Portrait down
                    setPitchAndRoll(reading.xRotation, reading.yRotation, OrientationReading.TopDown);
                    break;

                case 8: // Landscape down
                    setPitchAndRoll(reading.xRotation, reading.yRotation, OrientationReading.LeftUp);
                    break;
                }
                break;
            }

            tiltReading = reading;
        }
    }

    //--------------------------------------------------------------------------

    RotationSensor {
        id: rotationSensor

        active: false
        axesOrientationMode: Sensor.FixedOrientation

        onReadingChanged: {
            // XXX roll angles from the rotation sensor are way off if pitch > -60 deg, i.e. larger
            // than 30 degree from horizontal, it looks as if we need to use the tilt values in any case
            switch (orientation) {
            case OrientationReading.TopUp:
            case OrientationReading.TopDown:
            case OrientationReading.LeftUp:
            case OrientationReading.RightUp:
                setAzimuthFromRot(reading.z, orientation);
                break;

            case OrientationReading.FaceUp:
            case OrientationReading.FaceDown:
                setAzimuthFromRot(reading.z, lastOrientation);
                break;

            case OrientationReading.Undefined:
            default:
                switch (Screen.orientation) {
                case 1: // Portrait up
                    setAzimuthFromRot(reading.z, OrientationReading.TopUp);
                    break;

                case 2: // Landscape up
                    setAzimuthFromRot(reading.z, OrientationReading.RightUp);
                    break;

                case 4: // Portrait down
                    setAzimuthFromRot(reading.z, OrientationReading.TopDown);
                    break;

                case 8: // Landscape down
                    setAzimuthFromRot(reading.z, OrientationReading.LeftUp);
                    break;
                }
                break;
            }

            rotationReading = reading;
        }
    }

    //--------------------------------------------------------------------------

    Gyroscope {
        id: gyroscope

        active: false
        axesOrientationMode: Sensor.FixedOrientation

        onReadingChanged: {
            // Note that the sensor readings are angular velocities around the *current*
            // fixed device axes.
            //
            // If the device is horizontal, a change in azimuth corresponds to a change
            // in angular velocity around the z axis, but if the device is vertical a
            // change in azimuth corresponds to a change in angular velocity around the
            // y axis. If the device is held at e.g. 45 degrees, a change in azimuth
            // corresponds to a change in both z and y axis!
            //
            // Thus, it's easier to watch the magnitude of the angular velocities vector
            // if we are only interested in whether the device rotates or not.
            sensorTurnVelocity = Math.sqrt(reading.x*reading.x + reading.y*reading.y + reading.z*reading.z);

            gyroscopeReading = reading;
        }
    }

    //--------------------------------------------------------------------------

    OrientationSensor {
        id: orientationSensor

        active: false

        onReadingChanged: {
            orientation = reading.orientation

            if (orientation !== OrientationReading.FaceUp && orientation !== OrientationReading.FaceDown && orientation !== OrientationReading.Undefined) {
                lastOrientation = orientation;
            }
        }
    }

    //--------------------------------------------------------------------------

    function setAzimuthFromMag(azimuth, orientation) {
        switch (orientation) {
        case OrientationReading.TopUp:
            if (rotationSensor.hasZ && !isWindows) {
                sensorAzimuth = Math.abs(beyondVerticalIndicator) <= 90 ? normAngle(azimuth) : normAngle(azimuth + 180);
            } else {
                sensorAzimuth = normAngle(azimuth);
            }
            break;

        case OrientationReading.TopDown:
            sensorAzimuth = normAngle(azimuth + 180);
            break;

        case OrientationReading.RightUp:
            sensorAzimuth = normAngle(azimuth + 90);
            break;

        case OrientationReading.LeftUp:
            sensorAzimuth = normAngle(azimuth - 90);
            break;
        }
    }

    //--------------------------------------------------------------------------

    // Note that yaw and bearing are oriented differently, thus the minus sign
    function setAzimuthFromRot(yaw, orientation) {
        switch (orientation) {
        case OrientationReading.TopUp:
            if (rotationSensor.hasZ && !isWindows) {
                sensorYawAngle = Math.abs(beyondVerticalIndicator) <= 90 ? normAngle(-yaw) : normAngle(-yaw + 180);
            } else {
                sensorYawAngle = normAngle(-yaw);
            }
            break;

        case OrientationReading.TopDown:
            sensorYawAngle = normAngle(-yaw + 180);
            break;

        case OrientationReading.RightUp:
            sensorYawAngle = normAngle(-yaw + 90);
            break;

        case OrientationReading.LeftUp:
            sensorYawAngle = normAngle(-yaw - 90);
            break;
        }
    }

    //--------------------------------------------------------------------------

    function setPitchAndRoll(xRotation, yRotation, orientation) {
        switch (orientation) {
        case OrientationReading.TopUp:
            sensorPitchAngle = Math.abs(beyondVerticalIndicator) <= 90 ? - (90 - xRotation) : 90 - xRotation;
            sensorRollAngle = yRotation;
            break;

        case OrientationReading.TopDown:
            sensorPitchAngle = Math.abs(beyondVerticalIndicator) <= 90 ? - (90 + xRotation) : 90 + xRotation;
            sensorRollAngle = -yRotation;
            break;

        case OrientationReading.RightUp:
            sensorPitchAngle = Math.abs(beyondVerticalIndicator) <= 90 ? - (90 + yRotation) : 90 + yRotation;
            sensorRollAngle = xRotation;
            break;

        case OrientationReading.LeftUp:
            sensorPitchAngle = Math.abs(beyondVerticalIndicator) <= 90 ? - (90 - yRotation) : 90 - yRotation;
            sensorRollAngle = -xRotation;
            break;
        }
    }

    //--------------------------------------------------------------------------

    function startRequiredAttitudeSensors(manualCompass, manualPitch, manualRoll, useRotationZAsAzimuth, azimuthFilterType, attitudeFilterType) {
        if (manualCompass && manualPitch && manualRoll) {

            stopCompass();
            stopTiltSensor();
            stopRotationSensor();

        } else {

            if (!manualCompass) {
                startCompass();
                if (hasZRotationSensor) {
                    startRotationSensor();
                }
            } else {
                stopCompass();
            }

            if (!manualPitch || !manualRoll) {
                startTiltSensor();
                startRotationSensor();
            } else {
                stopTiltSensor();
                if (!hasZRotationSensor && !useRotationZAsAzimuth) {
                    stopRotationSensor();
                }
            }

        }

        if ((!manualCompass && azimuthFilterType !== 0 ) || ((!manualPitch || !manualRoll) && attitudeFilterType !== 0)) {
            startGyroscope();
        } else {
            stopGyroscope();
        }
    }

    //--------------------------------------------------------------------------

    function startPositionSource() {
        if (positionSource && !positionSource.active) {
            positionSource.activate();
        }
    }

    function startCompass() {
        if (compass && !compass.active) {
            console.log("starting compass");
            compass.start();
        }
    }

    function startTiltSensor() {
        if (tiltSensor && !tiltSensor.active) {
            console.log("starting tilt sensor");
            tiltSensor.start();
        }
    }

    function startRotationSensor() {
        if (rotationSensor && !rotationSensor.active) {
            console.log("starting rotation sensor");
            rotationSensor.start();
        }
    }

    function startGyroscope() {
        if (gyroscope && !gyroscope.active) {
            console.log("starting gyroscope");
            gyroscope.start();
        }
    }

    function startOrientationSensor() {
        if (orientationSensor && !orientationSensor.active) {
            console.log("starting orientation sensor");
            orientationSensor.start();
        }
    }

    //--------------------------------------------------------------------------

    function stopPositionSource() {
        if (positionSource && positionSource.active) {
            console.log("stopping position source");
            positionSource.stop();
        }
    }

    function stopCompass() {
        if (compass && compass.active) {
            console.log("stopping compass");
            compass.stop();
        }
    }

    function stopTiltSensor() {
        if (tiltSensor && tiltSensor.active) {
            console.log("stopping tilt sensor");
            tiltSensor.stop();
        }
    }

    function stopRotationSensor() {
        if (rotationSensor && rotationSensor.active) {
            console.log("stopping rotation sensor");
            rotationSensor.stop();
        }
    }

    function stopGyroscope() {
        if (gyroscope && gyroscope.active) {
            console.log("stopping gyroscope");
            gyroscope.stop();
        }
    }

    function stopOrientationSensor() {
        if (orientationSensor && orientationSensor.active) {
            console.log("stopping orientation sensor");
            orientationSensor.stop();
        }
    }

    //--------------------------------------------------------------------------

    function resetAzimuthFilter(value) {
        azimuthFilter.reset(value);
    }

    function resetPitchAngleFilter(value) {
        pitchAngleFilter.reset(value);
    }

    function resetRollAngleFilter(value) {
        rollAngleFilter.reset(value);
    }

    function resetTurnVelocityFilter(value) {
        turnVeolictyFilter.reset(value);
    }

    function resetPitchVelocityFilter(value) {
        pitchVeolictyFilter.reset(value);
    }

    function resetRollVelocityFilter(value) {
        rollVeolictyFilter.reset(value);
    }

    //--------------------------------------------------------------------------

    function checkSensorAvailability() {
        var sensorTypes = QmlSensors.sensorTypes();
        console.log("Sensor types:", sensorTypes.join(", "));

        hasCompass = sensorTypes.indexOf("QCompass") >= 0;
        hasTiltSensor = sensorTypes.indexOf("QTiltSensor") >= 0;
        hasRotationSensor = sensorTypes.indexOf("QRotationSensor") >= 0;
        hasGyroscope = sensorTypes.indexOf("QGyroscope") >= 0;

        hasPitchSensor = hasTiltSensor || hasRotationSensor;
        hasRollSensor = hasTiltSensor || hasRotationSensor;
        hasZRotationSensor = hasRotationSensor && rotationSensor.hasZ;
    }

    //--------------------------------------------------------------------------

    function calculateRotationSensorCalibration() {
        if (!deviceTurning) {
            var azimuthRelDiff = Math.abs(sensors.azimuthFromMagNorth - sensors.azimuthFromYawAngle) / kMaxRotationSensorCalibrationThreshold;
            var calibrationLevel = azimuthRelDiff <= 1 ? Math.round( (1.0 - azimuthRelDiff) * 3 ) / 3 : 0;
            lastCalibrationLevel = calibrationLevel;
            return calibrationLevel
        }

        return lastCalibrationLevel;
    }

    //--------------------------------------------------------------------------

    function normAngle(angle) {
        return (angle + 360) % 360;
    }

    //--------------------------------------------------------------------------
}
