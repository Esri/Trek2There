import QtQml 2.2
import QtQuick 2.5
import QtQuick.Controls 1.4
import QtPositioning 5.3
import QtMultimedia 5.5

import ArcGIS.AppFramework 1.0

//import "AppControls"

import "js/MathLib.js" as MathLib

Item {

    Item {
        id: viewData
        property real fieldOfViewX: 48.5
        property real fieldOfViewY: 62

        property real deviceBearing: 0
        property real devicePitch: 0
        property real deviceRoll: 0

        property var observerCoordinate: QtPositioning.coordinate
        property var itemCoordinate: QtPositioning.coordinate
        property real observerHeight: 0.0
        property real itemHeight: 0.0

        //----------------------------------------------------------------------

        function setPosition(position, threshold) {
            if (threshold > 0) {
                var distance = position.coordinate.distanceTo(observerCoordinate);

                if (distance < threshold) {
                    return;
                }
            }

            var longitude = position.coordinate.longitude;
            var latitude = position.coordinate.latitude;
            var altitude = observerHeight;

            observerCoordinate = QtPositioning.coordinate(latitude, longitude, altitude);

            console.log("observerCoordinate:", observerCoordinate);
        }
    }

    HUDSensors {
        id: sensors

        azimuthFilterType: 0 // 0=rounding 1=smoothing
        azimuthRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
        azimuthFilterLength: 10
        attitudeFilterType: 0 // 0=rounding 1=smoothing
        attitudeRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
        attitudeFilterLength: 10
        magneticDeclination: 0.0

        onPositionChanged: updatePosition()

        onAzimuthFromTrueNorthChanged: updateBearing()

        onPitchAngleChanged: updatePitch()

        onRollAngleChanged: updateRoll()

        function updatePosition() {
            if (position.latitudeValid && position.longitudeValid) {
                viewData.setPosition(position, viewConfig.locationThreshold);
            }
        }

        function updateBearing() {
            if (sensors.azimuthFromTrueNorth) {
                viewData.deviceBearing = sensors.azimuthFromTrueNorth;
            }
        }

        function updatePitch() {
            if (sensors.pitchAngle) {
                viewData.devicePitch = sensors.pitchAngle;
            }
        }

        function updateRoll() {
            if (sensors.rollAngle) {
                viewData.deviceRoll = sensors.rollAngle;
            }
        }
    }

    Canvas {
        id: overlay

        //----------------------------------------------------------------------

        clip: true

        //----------------------------------------------------------------------

        Connections {
            target: viewData

            onObserverCoordinateChanged: {
                requestPaint();
            }

            onItemCoordinateChanged: {
                requestPaint();
            }

            onDeviceBearingChanged: {
                requestPaint();
            }

            onDevicePitchChanged: {
                requestPaint();
            }

            onDeviceRollChanged: {
                requestPaint();
            }

            onFieldOfViewXChanged: {
                requestPaint();
            }

            onFieldOfViewYChanged: {
                requestPaint();
            }
        }

        //--------------------------------------------------------------------------

        onPaint: {
            var context = getContext("2d");
            context.save();
            context.clearRect(0, 0, width, height);

            adjustScaling();

            context.beginPath();
            context.rect(offsetx, offsety, scalex, scaley);
            context.clip();

            MathLib.initializeTransformationMatrix(viewData.observerHeight, viewData.deviceBearing, viewData.devicePitch, viewData.deviceRoll, viewData.fieldOfViewX, viewData.fieldOfViewY);

            updateViewModel(context);

            context.restore();
        }

        //--------------------------------------------------------------------------

        function adjustScaling() {
            var rect = videoOutput.contentRect;
            scalex = rect.width;
            scaley = rect.height;
            offsetx = rect.x;
            offsety = rect.y;
        }

        function toScreenCoord(pt) {
            return (pt ? Qt.vector2d(scalex * pt.x + offsetx, scaley * pt.y + offsety) : null);
        }

        //--------------------------------------------------------------------------

        function updateViewModel(context) {
            var distance = viewData.observerCoordinate.distanceTo(viewData.itemCoordinate);
            var azimuth = viewData.observerCoordinate.azimuthTo(viewData.itemCoordinate);

            var inFoV = MathLib.inFieldOfView(azimuth, viewData.deviceBearing, viewData.deviceRoll, viewData.fieldOfViewX, viewData.fieldOfViewY);
            if (!inFoV) {
                continue;
            }

            var pointInPlane = MathLib.transformAzimuthToCamera(azimuth, distance, viewData.itemHeight - viewData.observerHeight);
            if (!pointInPlane || pointInPlane.x < 0 || pointInPlane.x > 1 || pointInPlane.y < 0 || pointInPlane.y > 1) {
                continue;
            }

            var viewCoords = toScreenCoord(pointInPlane);
            drawPoint(context, viewCoords, 1.0, "red");
        }

        //--------------------------------------------------------------------------

        function drawPoint(context, pt, scale, color) {
            var r = 5 * AppFramework.displayScaleFactor * scale;
            context.beginPath();
            context.arc(pt.x, pt.y, r, 0, 2 * Math.PI);
            context.fillStyle = color;
            context.fill();
        }
    }
}

