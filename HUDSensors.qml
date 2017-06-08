import QtQuick 2.8
import QtQuick.Window 2.2
import QtPositioning 5.8
import QtSensors 5.5

import ArcGIS.AppFramework 1.0

Item {
    id: sensors

    // XXX Temporary fix for issue 106: Windows sensor orientation differences
    readonly property bool isWindows: Qt.platform.os === "windows"
    readonly property real beyondVerticalIndicator:
        rotationSensor.active && rotationSensor.reading
        ? isWindows
        ? rotationSensor.reading.x
        : rotationSensor.reading.y
        : 0.0;

    readonly property int kFilterSizeThreshold: 5
    readonly property real kAngularVelocityThreshold: 5

    property alias positionSource: positionSource
    property alias compass: compass
    property alias tiltSensor: tiltSensor
    property alias rotationSensor: rotationSensor
    property alias orientationSensor: orientationSensor
    property alias gyroscope: gyroscope

    property alias azimuthFilter: azimuthFilter
    property alias pitchAngleFilter: pitchAngleFilter
    property alias rollAngleFilter: rollAngleFilter

    property bool hasCompass
    property bool hasTiltSensor
    property bool hasRotationSensor
    property bool hasGyroscope

    property bool hasPitchSensor
    property bool hasRollSensor
    property bool hasZRotationSensor

    //--------------------------------------------------------------------------

    property real movementThreshold: 3

    // filtered sensor readings
    property real azimuthFromTrueNorth: normAngle(azimuthFromMagNorth + magneticDeclination)
    property real azimuthFromMagNorth: sensorAzimuth
    property real pitchAngle: sensorPitchAngle
    property real rollAngle: sensorRollAngle
    property real turnVelocity: sensorTurnVelocity
    property real pitchVelocity: sensorPitchVelocity
    property real rollVelocity: sensorRollVelocity

    // unfiltered sensor readings
    property real sensorAzimuth: 0
    property real sensorPitchAngle: 0
    property real sensorRollAngle: 0
    property real sensorTurnVelocity: 0
    property real sensorPitchVelocity: 0
    property real sensorRollVelocity: 0

    // raw sensor readings
    property Position position
    property CompassReading compassReading
    property TiltReading tiltReading
    property RotationReading rotationReading
    property GyroscopeReading gyroscopeReading

    property var orientation: OrientationReading.TopUp
    property var lastOrientation: OrientationReading.TopUp
    property real magneticDeclination: 0
    property bool useRotationZAsAzimuth: false

    property int azimuthFilterType: 0 // 0=rounding 1=smoothing
    property int azimuthRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
    property int azimuthFilterLength: 10

    property int attitudeFilterType: 0 // 0=rounding 1=smoothing
    property int attitudeRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
    property int attitudeFilterLength: 10

    property bool azimuthTurning: false
    property bool pitchTurning: false
    property bool rollTurning: false
    property bool debug: false

    signal sensorPositionChanged()
    signal positionSourceActiveChanged()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        checkSensorAvailability();
    }

    //--------------------------------------------------------------------------

    onSensorAzimuthChanged: {
        if (azimuthFilterType == 0) {
            azimuthFromMagNorth = azimuthRounding > 0
                    ? Math.round(sensorAzimuth * azimuthRounding) / azimuthRounding
                    : sensorAzimuth;
        } else {
             azimuthFromMagNorth = azimuthFilter.update(sensorAzimuth);
        }
    }

    onSensorPitchAngleChanged: {
        if (attitudeFilterType == 0) {
            pitchAngle = attitudeRounding > 0
                    ? Math.round(sensorPitchAngle * attitudeRounding) / attitudeRounding
                    : sensorPitchAngle;
        } else {
            pitchAngle = pitchAngleFilter.update(sensorPitchAngle);
        }
    }

    onSensorRollAngleChanged: {
        if (attitudeFilterType == 0) {
            rollAngle = attitudeRounding > 0
                    ? Math.round(sensorRollAngle * attitudeRounding) / attitudeRounding
                    : sensorRollAngle;
        } else {
            rollAngle = rollAngleFilter.update(sensorRollAngle);
        }
    }

    onSensorTurnVelocityChanged: {
        turnVelocity = turnVelocityFilter.update(sensorTurnVelocity);
    }

    onSensorPitchVelocityChanged: {
        pitchVelocity = pitchVelocityFilter.update(sensorPitchVelocity);
    }

    onSensorRollVelocityChanged: {
        rollVelocity = rollVelocityFilter.update(sensorRollVelocity);
    }

    onTurnVelocityChanged: {
        if (azimuthFilterType != 0) {
            if (azimuthFilter.size >= kFilterSizeThreshold) {
                if (!azimuthTurning && Math.abs(turnVelocity) >= kAngularVelocityThreshold) {
                    azimuthTurning = true;
                    azimuthFilter.size = kFilterSizeThreshold;
                } else if (azimuthTurning && Math.abs(turnVelocity) < kAngularVelocityThreshold) {
                    azimuthTurning = false;
                    azimuthFilter.size = azimuthFilterLength;
                }
            }
        }
    }

    onPitchVelocityChanged: {
        if (attitudeFilterType != 0) {
            if (pitchAngleFilter.size >= kFilterSizeThreshold) {
                if (!pitchTurning && Math.abs(pitchVelocity) >= kAngularVelocityThreshold) {
                    pitchTurning = true;
                    pitchAngleFilter.size = kFilterSizeThreshold;
                } else if (pitchTurning && Math.abs(pitchVelocity) < kAngularVelocityThreshold) {
                    pitchTurning = false;
                    pitchAngleFilter.size = attitudeFilterLength;
                }
            }
        }
    }

    onRollVelocityChanged: {
        if (attitudeFilterType != 0) {
            if (rollAngleFilter.size >= kFilterSizeThreshold) {
                if (!rollTurning && Math.abs(rollVelocity) >= kAngularVelocityThreshold) {
                    rollTurning = true;
                    rollAngleFilter.size = kFilterSizeThreshold;
                } else if (rollTurning && Math.abs(rollVelocity) < kAngularVelocityThreshold) {
                    rollTurning = false;
                    rollAngleFilter.size = attitudeFilterLength;
                }
            }
        }
    }

    onPositionChanged: {

    } 

    positionSource.onActiveChanged: {
        positionSourceActiveChanged();
    }

    //--------------------------------------------------------------------------

    HUDSensorFilter{
        id: azimuthFilter

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

    HUDSensorFilter {
        id: pitchVelocityFilter

        size: kFilterSizeThreshold
    }

    HUDSensorFilter {
        id: rollVelocityFilter

        size: kFilterSizeThreshold
    }

    //--------------------------------------------------------------------------

    PositionSource {
        id: positionSource

        property date activatedTimestamp
        property bool positionUpToDate

        updateInterval: 1000

        active: false

        onActiveChanged: {
            if (active) {
                activatedTimestamp = new Date();
                positionUpToDate = position.timestamp > activatedTimestamp;
            }
            else {
                positionUpToDate = false;
            }
        }

        onPositionChanged: {
            console.log("poz change")

            positionUpToDate = position.timestamp > activatedTimestamp;

            if (position.latitudeValid && position.longitudeValid && positionUpToDate) {
                if (debug) {
                    console.log("position:", position.coordinate, position.timestamp);
                }
                sensors.position = position;
                sensorPositionChanged();
            }
        }

        function activate() {
            console.log("Starting position source:", name);

            AppFramework.environment.setValue("APPSTUDIO_POSITION_DESIRED_ACCURACY", "HIGHEST");
            AppFramework.environment.setValue("APPSTUDIO_POSITION_ACTIVITY_MODE", "OTHERNAVIGATION");
            AppFramework.environment.setValue("APPSTUDIO_POSITION_MOVEMENT_THRESHOLD", movementThreshold.toString());

            start();
        }
    }

    //--------------------------------------------------------------------------

    Compass {
        id: compass

        active: false
        axesOrientationMode: Sensor.AutomaticOrientation

        onReadingChanged: {
            if (!useRotationZAsAzimuth) {
                switch (orientation) {
                case OrientationReading.TopUp:
                case OrientationReading.TopDown:
                case OrientationReading.LeftUp:
                case OrientationReading.RightUp:
                    setAzimuth(reading.azimuth, orientation);
                    break;

                case OrientationReading.FaceUp:
                case OrientationReading.FaceDown:
                    setAzimuth(reading.azimuth, lastOrientation);
                    break;

                case OrientationReading.Undefined:
                default:
                    switch (Screen.orientation) {
                    case 1: // Portrait up
                        setAzimuth(reading.azimuth, OrientationReading.TopUp);
                        break;

                    case 2: // Landscape up
                        setAzimuth(reading.azimuth, OrientationReading.LeftUp);
                        break;

                    case 4: // Portrait down
                        setAzimuth(reading.azimuth, OrientationReading.TopDown);
                        break;

                    case 8: // Landscape down
                        setAzimuth(reading.azimuth, OrientationReading.RightUp);
                        break;
                    }
                    break;
                }
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
            // XXX roll angles from the rotation sensor are way off if pitch > -60 deg, i.e. larger
            // than 30 degree from horizontal, it looks as if we need to use the tilt values in any case
            // if (!useRotationZAsAzimuth) {
                switch (orientation) {
                case OrientationReading.TopUp:
                case OrientationReading.TopDown:
                case OrientationReading.LeftUp:
                case OrientationReading.RightUp:
                    setTiltAngles(reading.xRotation, reading.yRotation, orientation);
                    break;

                case OrientationReading.FaceUp:
                case OrientationReading.FaceDown:
                    setTiltAngles(reading.xRotation, reading.yRotation, lastOrientation);
                    break;

                case OrientationReading.Undefined:
                default:
                    switch (Screen.orientation) {
                    case 1: // Portrait up
                        setTiltAngles(reading.xRotation, reading.yRotation, OrientationReading.TopUp);
                        break;

                    case 2: // Landscape up
                        setTiltAngles(reading.xRotation, reading.yRotation, OrientationReading.LeftUp);
                        break;

                    case 4: // Portrait down
                        setTiltAngles(reading.xRotation, reading.yRotation, OrientationReading.TopDown);
                        break;

                    case 8: // Landscape down
                        setTiltAngles(reading.xRotation, reading.yRotation, OrientationReading.RightUp);
                        break;
                    }
                    break;
                }
            // }

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
            if (useRotationZAsAzimuth) {
                switch (orientation) {
                case OrientationReading.TopUp:
                case OrientationReading.TopDown:
                case OrientationReading.LeftUp:
                case OrientationReading.RightUp:
                    setAzimuth(-reading.z, orientation);
                    // setTiltAngles(reading.x, reading.y, orientation);
                    break;

                case OrientationReading.FaceUp:
                case OrientationReading.FaceDown:
                    setAzimuth(-reading.z, lastOrientation);
                    // setTiltAngles(reading.x, reading.y, lastOrientation);
                    break;

                case OrientationReading.Undefined:
                default:
                    switch (Screen.orientation) {
                    case 1: // Portrait up
                        setAzimuth(-reading.z, OrientationReading.TopUp);
                        // setTiltAngles(reading.x, reading.y, OrientationReading.TopUp);
                        break;

                    case 2: // Landscape up
                        setAzimuth(-reading.z, OrientationReading.LeftUp);
                        // setTiltAngles(reading.x, reading.y, OrientationReading.LeftUp);
                        break;

                    case 4: // Portrait down
                        setAzimuth(-reading.z, OrientationReading.TopDown);
                        // setTiltAngles(reading.x, reading.y, OrientationReading.TopDown);
                        break;

                    case 8: // Landscape down
                        setAzimuth(-reading.z, OrientationReading.RightUp);
                        // setTiltAngles(reading.x, reading.y, OrientationReading.RightUp);
                        break;
                    }
                    break;
                }
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
            sensorTurnVelocity = reading.z;
            sensorPitchVelocity = reading.x;
            sensorRollVelocity = reading.y;

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

    function setAzimuth(azimuth, orientation) {
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

    function setTiltAngles(xRotation, yRotation, orientation) {
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
        console.log(beyondVerticalIndicator, xRotation, sensorPitchAngle);
    }

    //--------------------------------------------------------------------------

    function startRequiredAttitudeSensors(manualCompass, manualPitch, manualRoll, useRotationZAsAzimuth, azimuthFilterType, attitudeFilterType) {
        if (manualCompass && manualPitch && manualRoll) {

            stopCompass();
            stopTiltSensor();
            stopRotationSensor();

        } else if (useRotationZAsAzimuth) {

            // XXX roll angles from the rotation sensor are way off if pitch > -60 deg, i.e. larger
            // than 30 degree from horizontal, it looks as if we need to use the tilt values in any case
            startRotationSensor();
            startTiltSensor();

            // stopTiltSensor();
            stopCompass();

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
                if (!hasZRotationSensor) {
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

    function normAngle(angle) {
        return (angle + 360) % 360;
    }

    //--------------------------------------------------------------------------
}
