/* Copyright 2017 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.8
import QtQml 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtMultimedia 5.8
import QtSensors 5.5

import ArcGIS.AppFramework 1.0

import "../"
import "../controls"
import "../js/MathLib.js" as MathLib

//------------------------------------------------------------------------------

Item {

    id: navigationView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool navigating: false
    property bool arrivedAtDestination: false
    property bool autohideToolbar: true
    property bool noPositionSource: false
    property double currentDistance: 0.0
    property int currentAccuracy: 0
    property int currentAccuracyInUnits: 0
    property int sideMargin: 14 * AppFramework.displayScaleFactor
    property bool hudOn: false

    // 2.0 Experimental Properties ---------------------------------------------

    property bool stopUsingCompassForNavigation: currentSpeed > maximumSpeedForCompass
    property double maximumSpeedForCompass: 0.9 // meters per second
    property double currentSpeed: 0.0
    property int kAzimuthRounding: 1
    property int kAzimuthFilterLength: 25
    property Image mapPin: Image { source: "../images/map_pin_night.png" }

    // Signals /////////////////////////////////////////////////////////////////

    signal arrived()
    signal reset()
    signal startNavigation()
    signal pauseNavigation()
    signal endNavigation()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        Screen.orientationUpdateMask = Qt.PortraitOrientation | Qt.InvertedPortraitOrientation | Qt.LandscapeOrientation | Qt.InvertedLandscapeOrientation
        selectBackCamera();
        camera.stop();
    }

    StackView.onDeactivated: {
        sensors.stopTiltSensor();
        sensors.stopOrientationSensor();
        sensors.stopRotationSensor();
        sensors.stopCompass();
        camera.stop();
    }

    StackView.onActivating: {
        sensors.startTiltSensor();
        sensors.startOrientationSensor();
        sensors.startRotationSensor();

        if (useExperimentalFeatures) {
            sensors.startCompass();
        }
    }

    StackView.onActivated: {
        if (requestedDestination !== null) {
            viewData.itemCoordinate = requestedDestination;
            startNavigation();
        }
    }

    //--------------------------------------------------------------------------

    onStopUsingCompassForNavigationChanged: {
        if (useExperimentalFeatures) {
            if (stopUsingCompassForNavigation) {
                sensors.stopCompass();
            } else {
                sensors.startCompass();
            }
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    // MouseArea ---------------------------------------------------------------

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: autohideToolbar ? true : false

        onClicked: {
            if (toolbar.opacity === 0) {
                toolbar.opacity = 1;
                toolbar.enabled = true;
                hideToolbar.start();
            }
        }

        onPressAndHold: {
            if (!isAndroid && !isIOS && useExperimentalFeatures) {
                if (hudOn) {
                    turnHudOff();
                } else {
                    turnHudOn();
                }
            }
        }

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Show bottom toolbar")
        Accessible.description: qsTr("This mouse area acts as a button and will show the bottom tool bar if it is hidden.")
        Accessible.focusable: true
        Accessible.onPressAction: {
            clicked(null);
        }
    }

    // Main View Container -----------------------------------------------------

    Rectangle {
        id: mainViewContainer

        anchors.fill: parent

        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
        Accessible.role: Accessible.Pane

        // Background video in experimental mode -------------------------------

        VideoOutput {
            id: videoOutput

            visible: hudOn
            enabled: visible

            anchors.fill: parent

            fillMode: VideoOutput.PreserveAspectCrop
            autoOrientation: Qt.platform.os === "windows" ? false : true

            source: Camera {
                id: camera

                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

                focus {
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointAuto
                }

                exposure {
                    exposureCompensation: -1.0
                    exposureMode: Camera.ExposurePortrait
                }

                captureMode: Camera.CaptureStillImage
                flash.mode: Camera.FlashRedEyeReduction

                position: Camera.BackFace

                onCameraStatusChanged: {
                    if (cameraStatus === Camera.ActiveStatus) {
                        fadeHudIn.start();
                    }
                }

                Component.onCompleted: camera.stop()
            }
        }

        // Resizable Navigation View Container ---------------------------------

        Item {
            id: viewContainer

            x: 0
            y: 0
            width: parent.width
            height: parent.height

            states: State {
                name: "landscape"
                when: isLandscape

                PropertyChanges {
                    target: viewContainer
                    width: parent.width/2
                }
            }

            transitions: Transition {
                from: ""
                to: "landscape"
                reversible: true

                NumberAnimation { properties: "width"; duration: 500; easing.type: Easing.InOutQuad }
            }

            // HUD View ------------------------------------------------------------

            Item {
                id: hudView

                visible: hudOn
                enabled: visible

                anchors.fill: parent

                //------------------------------------------------------------------

                Canvas {
                    id: overlay

                    visible: hudOn && requestedDestination !== null
                    enabled: visible

                    anchors.fill: parent
                    clip: true

                    property var viewCoords
                    property double scale: 1
                    property int offsetx: videoOutput.contentRect.x
                    property int offsety: videoOutput.contentRect.y
                    property int scalex: videoOutput.contentRect.width
                    property int scaley: videoOutput.contentRect.height

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.save();

                        ctx.clearRect(0, 0, width, height);

                        drawSymbol(ctx, viewCoords, scale);

                        ctx.restore();
                    }

                    function drawSymbol(ctx, viewCoords, scale) {
                        if (viewCoords) {
                            var size = Math.ceil(sf(50) * scale);
                            var centeredY = overlay.height / 2 - size; // pt.y - size;
                            var centeredX = viewCoords.x - overlay.width / 2 - size/2;
                            ctx.drawImage(mapPin.source, centeredX, centeredY, size, size);
                        }
                    }
                }

                //------------------------------------------------------------------

                Rectangle {
                    id: rect

                    visible: hudOn && requestedDestination !== null
                    enabled: visible

                    width: sf(200)
                    height: sf(200)

                    x: parent.width/2 - width/2
                    y: parent.height - height*0.66 - toolbar.height - (!isLandscape ? distanceReadoutContainer.height : 0)
                    z: 10000

                    radius: 5
                    opacity: .8
                    color: "green"
                    transform: Rotation { origin.x: sf(100); origin.y: sf(100); axis { x: 1; y: 0 ; z: 0 } angle: 75 }

                    Image {
                        id: hudDirectionArrow

                        anchors.centerIn: parent
                        height: parent.height - sf(40)

                        source: "../images/arrow_night.png"
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }

            // Arrow View --------------------------------------------------------------

            ColumnLayout {
                id: arrowView

                anchors.fill: parent
                visible: requestedDestination !== null
                spacing: 0

                Accessible.role: Accessible.Pane

                // ---------------------------------------------------------

                Item {
                    Layout.preferredHeight: statusMessageContainer.height
                }

                // ---------------------------------------------------------

                Item {
                    id: directionUI

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Accessible.role: Accessible.Pane

                    z: 99

                    property int imageBorder: 40 * AppFramework.displayScaleFactor

                    Image {
                        id: directionOfTravelCircle

                        visible: useDirectionOfTravelCircle && !noPositionSource

                        anchors.centerIn: parent
                        height: directionUI.height - directionUI.imageBorder
                        width: directionUI.width - directionUI.imageBorder

                        source: "../images/direction_of_travel_circle.png"
                        fillMode: Image.PreserveAspectFit
                        Accessible.ignored: true
                    }

                    Image {
                        id: directionArrow

                        visible: !noPositionSource

                        anchors.centerIn: parent
                        width: 0.9 * directionOfTravelCircle.width
                        height: 0.9 * directionOfTravelCircle.height

                        source: !nightMode ? "../images/arrow_day.png" : "../images/arrow_night.png"
                        fillMode: Image.PreserveAspectFit
                        rotation: 0
                        opacity: 1

                        Accessible.role: Accessible.Indicator
                        Accessible.name: qsTr("Direction of travel is: %1".arg(rotation.toString()))
                        Accessible.description: qsTr("This arrow points toward the direction the user should travel. The degree is based off of the top of the device being the current bearing of travel.")
                        Accessible.ignored: arrivedAtDestination
                    }

                    Image {
                        id: arrivedIcon

                        visible: false

                        anchors.centerIn: parent
                        width: 0.9 * directionOfTravelCircle.width
                        height: 0.9 * directionOfTravelCircle.height

                        source: !nightMode ? "../images/map_pin_day.png" : "../images/map_pin_night.png"
                        fillMode: Image.PreserveAspectFit

                        Accessible.role: Accessible.AlertMessage
                        Accessible.name: qsTr("Arrived at destination")
                        Accessible.description: qsTr("You have arrived at your destination")
                        Accessible.ignored: navigating
                    }

                    Image {
                        id: noSignalIndicator

                        visible: noPositionSource && !arrivedAtDestination

                        anchors.centerIn: parent
                        height: directionUI.height - directionUI.imageBorder
                        width: directionUI.width - directionUI.imageBorder

                        source: "../images/no_signal.png"
                        fillMode: Image.PreserveAspectFit

                        Accessible.role: Accessible.Indicator
                        Accessible.name: qsTr("There is no signal")
                    }
                }

                // ---------------------------------------------------------

                Item {
                    Layout.preferredHeight: toolbar.height + (!isLandscape ? distanceReadoutContainer.height + directionUI.imageBorder / 2 : 0)
                }

                // ---------------------------------------------------------
            }
        }

        // Resizable Distance Readout ------------------------------------------

        Item {
            id: distanceReadoutContainer

            Accessible.role: Accessible.Pane

            x: 0
            y: parent.height - height - toolbar.height - directionUI.imageBorder / 2
            width: parent.width
            height: sf(100)

            states: State {
                name: "landscape"
                when: isLandscape

                PropertyChanges {
                    target: distanceReadoutContainer
                    x: parent.width/2
                    y: parent.height/2 - distanceReadoutContainer.height/2
                    width: parent.width/2
                }
            }

            transitions: Transition {
                from: ""
                to: "landscape"
                reversible: true
                NumberAnimation { properties: "x,y,width"; duration: 500; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                visible: requestedDestination !== null

                anchors.centerIn: parent
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    id: distanceReadout

                    Layout.fillWidth: true

                    text: displayDistance(currentDistance.toString())
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: extraLargeFontSize
                    font.weight: Font.Light
                    fontSizeMode: Text.Fit
                    minimumPointSize: largeFontSize
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground

                    Accessible.role: Accessible.Indicator
                    Accessible.name: text
                    Accessible.description: qsTr("This value is the distance remaining between you and the destination")
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: sf(0)

                    Text {
                        id: bearingReadout

                        text: qsTr("%1° %2").arg(Math.round((currentPosition.degreesOffCourse+360) % 360).toFixed(0)).arg(cardinalDirection(directionArrow.rotation))
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: largeFontSize
                        minimumPointSize: largeFontSize
                        color: currentAccuracy <= 0 ? "#aaa" : buttonTextColor

                        Accessible.role: Accessible.Indicator
                        Accessible.name: text
                        Accessible.description: qsTr("Bearing in degrees")
                    }

                    Rectangle {
                        Layout.preferredWidth: sf(40)

                        color: "transparent"
                        Accessible.role: Accessible.Indicator
                        Accessible.name: qsTr("Location Accuracy Indicator")
                        Accessible.description: qsTr("Location accuracy is denoted on a scale of 1 to 5, with 1 being lowest and 5 being highest. Current location accuracy is rated %1".arg(currentAccuracy))

                        Text {
                            id: locationAccuracyBaseline

                            anchors.centerIn: parent

                            text: icons.accuracy_indicator
                            font.family: icons.name
                            font.pointSize: 24
                            color: currentAccuracy <= 0 ? "#aaa" : buttonTextColor
                            opacity: .4
                            z: 100

                            Accessible.ignored: true
                        }

                        Text {
                            id: locationAccuracyIndicator

                            visible: locationAccuracyBaseline && currentAccuracy > 0

                            anchors.centerIn: parent

                            text: currentAccuracy > 0 ? icons.getIconByName("accuracy" + currentAccuracy.toString()) : ""
                            font.family: icons.name
                            font.pointSize: 24
                            color: buttonTextColor
                            opacity: 1
                            z: locationAccuracyBaseline.z + 1

                            Accessible.ignored: true
                        }
                    }

                    Text {
                        id: accuracyInUnits

                        text: currentAccuracy > 0 ? qsTr("<p>&plusmn;%1%2</p>").arg(currentAccuracyInUnits.toString()).arg(usesMetric ? "m" : "ft") : "----"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: largeFontSize
                        minimumPointSize: largeFontSize
                        color: currentAccuracy <= 0 ? "#aaa" : buttonTextColor
                        opacity: currentAccuracy > 0 ? 1 : .4
                        textFormat: Text.RichText

                        Accessible.role: Accessible.Indicator
                        Accessible.name: qsTr("Accuracy in units is: %1".arg(text))
                        Accessible.description: qsTr("This denotes the current location accuracy in units rounded upward to the nearest %1".arg(usesMetric ? "meter" : "foot"))
                    }
                }
            }
        }

        // No Destination Message ----------------------------------------------

        Item {
            id: noDestinationSet

            visible: (requestedDestination === null) ? true : false

            anchors.fill: parent
            anchors.leftMargin: sideMargin
            anchors.rightMargin: sideMargin
            z: 100

            Accessible.role: Accessible.Pane

            Rectangle {
                anchors.centerIn: parent
                height: sf(80)
                width: parent.width
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                radius: sf(6)
                Accessible.role: Accessible.Pane

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        fontSizeMode: Text.Fit
                        wrapMode: Text.Wrap
                        font.pointSize: largeFontSize
                        minimumPointSize: 9
                        font.weight: Font.Black
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("No destination set!")
                        Accessible.role: Accessible.AlertMessage
                        Accessible.name: text
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        fontSizeMode: Text.Fit
                        wrapMode: Text.Wrap
                        font.pointSize: baseFontSize
                        minimumPointSize: 9
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        textFormat: Text.RichText
                        text: qsTr("Go to <span style='font-family:%1; font-size:%2pt; color:%3' alt='settings'>%4</span> to set your destination.".arg(icons.name).arg(font.pointSize * 1.2).arg(buttonTextColor).arg(icons.settings))
                        Accessible.role: Accessible.AlertMessage
                        Accessible.name: qsTr("Click the settings button in the bottom toolbar to set your destination")
                    }
                }
            }
        }
    }

    // Status Message ----------------------------------------------------------

    Item {
        id: statusMessageContainer
        width: parent.width
        height: sf(50)
        anchors.top: parent.top
        visible: true
        Accessible.role: Accessible.Pane

        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: sf(10)
            anchors.leftMargin: sf(10)
            anchors.topMargin: sf(10)

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                StatusIndicator {
                    id: statusMessage
                    visible: false
                    anchors.fill: parent
                    containerHeight: parent.height
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    hideAutomatically: false
                    animateHide: false
                    messageType: statusMessage.warning
                    message: qsTr("Start moving to determine direction.")

                    Accessible.role: Accessible.AlertMessage
                    Accessible.name: message
                }
            }
        }
    }

    // Toolbar -----------------------------------------------------------------

    Item {
        id: toolbar
        width: parent.width
        height: sf(50)
        anchors.bottom: parent.bottom
        opacity: 1
        Accessible.role: Accessible.Pane
        Accessible.name: qsTr("Toolbar")
        Accessible.description: qsTr("This toolbar contains the settings button, the end navigation button and the day night mode switch button")

        RowLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            //----------------------------------------------------------

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: sf(50)
                Accessible.role: Accessible.Pane

                Button {
                    id: settingsButton
                    anchors.fill: parent
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Settings")

                    background: Rectangle{
                        color: "transparent"
                        anchors.fill: parent
                    }

                    Image {
                        id: settingsButtonIcon
                        anchors.centerIn: parent
                        height: parent.height - sf(24)
                        fillMode: Image.PreserveAspectFit
                        source: "../images/settings.png"
                    }

                    onClicked: {
                        if (navigating === false) {
                            reset();
                        }
                        mainStackView.push(settingsView);
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Settings")
                    Accessible.description: qsTr("Click button to go to the settings page where you can set your destination coordinates or change the units of measurement.")
                    Accessible.onPressAction: {
                        clicked(null);
                    }
                }
            }

            //----------------------------------------------------------

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Accessible.role: Accessible.Pane

                Button {
                    id: endNavigationButton
                    anchors.fill: parent
                    visible: false
                    enabled: false

                    background: Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: sf(2)
                        anchors.bottomMargin: sf(3)
                        color: "transparent"
                        border.width: sf(1)
                        border.color: !hudOn ? !nightMode ? dayModeSettings.buttonBorder : nightModeSettings.buttonBorder : buttonTextColor
                        radius: sf(5)

                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors.rightMargin: sf(15)
                        text: qsTr("End")
                        color: buttonTextColor
                    }

                    onClicked: {
                        endNavigation();
                        if (applicationCallback !== "") {
                            callingApplication = "";
                            Qt.openUrlExternally(applicationCallback);
                            applicationCallback = "";
                        }
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("End navigation")
                    Accessible.description: qsTr("Click this button to end navigation and reset the user interface. You will be taken back to the calling application if appropriate.")
                    Accessible.onPressAction: {
                        if (visible && enabled) {
                            clicked(null);
                        }
                    }
                }
            }

            //----------------------------------------------------------

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: sf(50)
                Accessible.role: Accessible.Pane

                Button {
                    id: viewModeButton
                    anchors.fill: parent
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("View Mode")

                    background: Rectangle {
                        color: "transparent"
                        anchors.fill: parent
                    }

                    Image {
                        id: viewModeButtonIcon
                        anchors.centerIn: parent
                        height: parent.height - sf(26)
                        fillMode: Image.PreserveAspectFit
                        source: "../images/contrast.png"
                    }

                    onClicked: {
                        nightMode = !nightMode ? true : false;
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Contrast mode")
                    Accessible.description: qsTr("Click this button to change the viewing mode contrast of the application.")
                    Accessible.onPressAction: {
                        clicked(null);
                    }
                }
            }
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onArrived: {
        arrivedAtDestination = true;
        navigating = false;
        sensors.positionSource.stop();
        directionArrow.visible = false
        arrivedIcon.visible = true
        distanceReadout.text = qsTr("Arrived");
        try {
            appMetrics.trackEvent("Arrived at destination.");
        }
        catch(e) {
            appMetrics.reportError(e, "onArrived");
        }
    }

    //--------------------------------------------------------------------------

    onReset: {
        console.log('reseting navigation')

        navigating = false;
        sensors.positionSource.active = false;
        sensors.positionSource.stop();

        statusMessage.hide();

        arrivedAtDestination = false;
        arrivedIcon.visible = false

        directionArrow.visible = true;
        directionArrow.rotation = 0;
        directionArrow.opacity = 1;

        hudDirectionArrow.rotation = 0;

        currentDistance = 0.0;
        distanceReadout.text = displayDistance(currentDistance.toString());

        currentAccuracy = 0;
        currentAccuracyInUnits = 0;

        if (autohideToolbar === true) {
            if (hideToolbar.running) {
                hideToolbar.stop();
            }
            if (fadeToolbar.running) {
                fadeToolbar.stop();
            }
            toolbar.opacity = 1;
            toolbar.enabled = true;
        }

    }

    //--------------------------------------------------------------------------

    onStartNavigation:{
        console.log('starting navigation')
        reset(); // TODO: This may cause some hiccups as positoin source is stopped and started. even though update is called, not sure all devices allow the update immedieately.
        navigating = true;

        sensors.positionSource.start();
        sensors.positionSource.update();
        currentPosition.destinationCoordinate = requestedDestination;
        sensors.positionSource.update();
        endNavigationButton.visible = true;
        endNavigationButton.enabled = true;

        if (autohideToolbar === true) {
            hideToolbar.start();
        }

        try {
            appMetrics.startSession();
            if (callingApplication !== null && callingApplication !== "") {
                appMetrics.trackEvent("App called from: " + callingApplication);
            }
        }
        catch(e) {
            appMetrics.reportError(e, "onStartNavigation");
        }

        if (logTreks) {
            trekLogger.startRecordingTrek();
        }
    }

    //--------------------------------------------------------------------------

    onPauseNavigation: {
    }

    //--------------------------------------------------------------------------

    onEndNavigation: {
        console.log('ending navigation')
        reset();
        navigating = false;
        endNavigationButton.visible = false;
        endNavigationButton.enabled = false;
        requestedDestination = null;

        if (logTreks) {
            trekLogger.stopRecordingTrek();
        }

        try {
            if (arrivedAtDestination === false) {
                appMetrics.trackEvent("Ended navigation without arrival.");
            }
        } catch(e) {
            appMetrics.reportError(e, "onEndNavigation");
        }

    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    CurrentPosition {
        id: currentPosition

        usingCompass: useExperimentalFeatures && (sensors.hasCompass && sensors.compass.active)

        onDistanceToDestinationChanged: {
            if (navigating) {
                distanceReadout.text = displayDistance(distanceToDestination);
            }
        }

        onDegreesOffCourseChanged: {
            if (degreesOffCourse === NaN || degreesOffCourse === 0) {
                noPositionSource = true;
                directionArrow.opacity = 0.2;
            }
            else {
                noPositionSource = false;
                directionArrow.opacity = 1;
                directionArrow.rotation = degreesOffCourse;
                hudDirectionArrow.rotation = degreesOffCourse;
            }
        }

        onAtDestination: {
            if (navigating) {
                arrived();
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: app

        onRequestedDestinationChanged: {
            console.log("requested Destination: ", requestedDestination);
            if (requestedDestination !== null) {
                startNavigation();
            }
        }
    }

    //--------------------------------------------------------------------------

    HUDSensors {
        id: sensors

        azimuthFilterType: Qt.platform.os === "android" ? 1 : 0 // 0=rounding 1=smoothing
        azimuthRounding: kAzimuthRounding // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
        azimuthFilterLength: kAzimuthFilterLength
        attitudeFilterType: 1 // 0=rounding 1=smoothing
        attitudeRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
        attitudeFilterLength: 25
        magneticDeclination: 0.0

        positionSource.onActiveChanged: {
            if (positionSource.active && viewData.observerCoordinate === null) {
                statusMessage.show();
            }
        }

        onSensorPositionChanged: {

            currentPosition.position = sensors.position;

            if (currentPosition.position.coordinate.isValid) {
                viewData.observerCoordinate = QtPositioning.coordinate(currentPosition.position.coordinate.latitude, currentPosition.position.coordinate.longitude, currentPosition.position.coordinate.altitude);
            }

            if (currentPosition.position.horizontalAccuracyValid) {
                var accuracy = currentPosition.position.horizontalAccuracy;
                if (accuracy < 10) {
                    currentAccuracy = 4;
                } else if (accuracy > 11 && accuracy < 55) {
                    currentAccuracy = 3;
                } else if (accuracy > 56 && accuracy < 100) {
                    currentAccuracy = 2;
                } else if (accuracy >= 100) {
                    currentAccuracy = 1;
                } else {
                    currentAccuracy = 0;
                }

                currentAccuracyInUnits = usesMetric ? Math.ceil(accuracy) : Math.ceil(accuracy * 3.28084)
            }

            if (currentPosition.position.speedValid) {
                currentSpeed = currentPosition.position.speed;
            }

            if (requestedDestination !== null) {
                /*
                    TODO: On some Android devices position.directionValid must return
                    true so the statusMessage isn't shown when navigation first starts
                    in order to inform the user to move. This isn't an issue on iOS.
                    May need to evaluate reset() method that hides the status
                    message as well as the startNavigation method as well to fix this.
                */
                if (currentPosition.position.directionValid) {
                    noPositionSource = false;
                    statusMessage.hide();
                    if (!useExperimentalFeatures || (useExperimentalFeatures && !sensors.compass.active)) {
                        viewData.deviceBearing = currentPosition.position.direction;
                    }
                }
                else {
                    noPositionSource = true;
                    directionArrow.opacity = 0.2;
                    statusMessage.show();
                }
            }
        }

        onPositionChanged: {}

        onAzimuthFromTrueNorthChanged: updateBearing()

        onPitchAngleChanged: updatePitch();

        onRollAngleChanged: updateRoll()

        function updateBearing() {
            if (sensors.azimuthFromTrueNorth) {
                if (viewData.observerCoordinate !== null /* && useCompass */) {
                    viewData.deviceBearing = sensors.azimuthFromTrueNorth;
                }
            }
        }

        function updatePitch() {
            if (!fadeHudIn.running && !fadeHudOut.running) {
                if (useExperimentalFeatures) {
                    if (!hudOn && Math.abs(sensors.pitchAngle) <= 30) {
                        turnHudOn();
                    } else if (hudOn && Math.abs(sensors.pitchAngle) > 30) {
                        turnHudOff();
                    }
                } else if (hudOn) {
                    turnHudOff();
                }
            }

            if (sensors.pitchAngle) {
                viewData.devicePitch = 0; // sensors.pitchAngle;
            }
        }

        function updateRoll() {
            if (sensors.rollAngle) {
                viewData.deviceRoll = 0; //sensors.rollAngle;
            }
        }
    }

    //--------------------------------------------------------------------------

    Item {
        id: viewData

        property real fieldOfViewX: 48.5
        property real fieldOfViewY: 62

        property real deviceBearing: 0
        property real devicePitch: 0
        property real deviceRoll: 0

        property var observerCoordinate: null
        property var itemCoordinate: null
        property real observerHeight: 1.6
        property real itemHeight: 0.0

        onObserverCoordinateChanged: {
            updateViewModel();
        }

        onItemCoordinateChanged: {
            updateViewModel();
        }

        onDeviceBearingChanged: {
            updateViewModel();
        }

        onDevicePitchChanged: {
            updateViewModel();
        }

        onDeviceRollChanged: {
            updateViewModel();
        }

        onFieldOfViewXChanged: {
            updateViewModel();
        }

        onFieldOfViewYChanged: {
            updateViewModel();
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: hideToolbar
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            fadeToolbar.start()
        }
    }

    //--------------------------------------------------------------------------

    PropertyAnimation{
        id: fadeToolbar

        from: 1
        to: 0
        duration: 1000
        property: "opacity"
        running: false
        easing.type: Easing.Linear
        target: toolbar

        onStopped: {
            toolbar.enabled = false;
            if (hideToolbar.running) {
                hideToolbar.stop();
            }
        }
    }

    //--------------------------------------------------------------------------

    SequentialAnimation {
        id: fadeHudIn

        running: false

        OpacityAnimator {
            target: arrowView
            from: arrowView.opacity
            to: 0
            duration: 700
        }

        ParallelAnimation {
            OpacityAnimator {
                target: videoOutput
                from: videoOutput.opacity
                to: 1
                duration: 700
            }

            OpacityAnimator {
                target: hudView
                from: hudView.opacity
                to: 1
                duration: 700
            }
        }

        onStarted: {
            hudOn = true;
        }
    }

    //--------------------------------------------------------------------------

    SequentialAnimation {
        id: fadeHudOut

        running: false

        ParallelAnimation {
            OpacityAnimator {
                target: videoOutput
                from: videoOutput.opacity
                to: 0
                duration: 700
            }

            OpacityAnimator {
                target: hudView
                from: hudView.opacity
                to: 0
                duration: 700
            }
        }

        OpacityAnimator {
            target: arrowView
            from: arrowView.opacity
            to: 1
            duration: 700
        }

        onStopped: {
            camera.stop();
            hudOn = false;
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    // -------------------------------------------------------------------------

    function turnHudOn() {
        // this will call fadeHudIn.start() once the camera is ready
        camera.start();
    }

    // -------------------------------------------------------------------------

    function turnHudOff() {
        fadeHudOut.start();
    }

    // -------------------------------------------------------------------------

    function updateViewModel() {
        MathLib.initializeTransformationMatrix(viewData.observerHeight, viewData.deviceBearing, viewData.devicePitch, viewData.deviceRoll, viewData.fieldOfViewX, viewData.fieldOfViewY);

        var distance = currentPosition.distanceToDestination;
        var azimuth = currentPosition.azimuthToDestination;

        if (useExperimentalFeatures && currentPosition.usingCompass) {
            var degreesOff = viewData.observerCoordinate !==null ? azimuth - sensors.sensorAzimuth : 0;
//            directionArrow.opacity = viewData.observerCoordinate !==null ? 1 : .4;
            currentPosition.degreesOffCourse = degreesOff;
        }

        var inFoV = MathLib.inFieldOfView(azimuth, viewData.deviceBearing, viewData.deviceRoll, viewData.fieldOfViewX, viewData.fieldOfViewY);
        if (!inFoV) {
            //console.log("Not in Field of view.")
        }

        var pointInPlane = MathLib.transformAzimuthToCamera(azimuth, distance, viewData.itemHeight - viewData.observerHeight);
        if (!pointInPlane || pointInPlane.x < 0 || pointInPlane.x > 1 || pointInPlane.y < 0 || pointInPlane.y > 1) {
            //console.log("point is not in the plane");
        }

        if (hudOn) {
            overlay.scale = (10000 - distance) / 10000 < .4 ? .4 : (10000 - distance) / 10000;
            overlay.viewCoords = toScreenCoord(pointInPlane);
            overlay.requestPaint();
        }
    }

    // -------------------------------------------------------------------------

    function toScreenCoord(pt) {
        return (pt ? Qt.vector2d(overlay.scalex * pt.x + overlay.offsetx, overlay.scaley * pt.y + overlay.offsety) : null);
    }

    // -------------------------------------------------------------------------

    function displayDistance(distance) {

        if (usesMetric === false) {
            var distanceFt = distance * 3.28084;
            if (distanceFt < 1000) {
                return "%1 ft".arg(Math.round(distanceFt).toLocaleString(locale, "f", 0))
            }
            else {
                var distanceMiles = distance * 0.000621371;
                return "%1 mi".arg((Math.round(distanceMiles * 10) / 10).toLocaleString(locale, "f", distanceMiles < 10 ? 1 : 0))
            }
        }
        else {
            if (distance < 1000) {
                return "%1 m".arg(Math.round(distance).toLocaleString(locale, "f", 0))
            }
            else {
                var distanceKm = distance / 1000;
                return "%1 km".arg((Math.round(distanceKm * 10) / 10).toLocaleString(locale, "f", distanceKm < 10 ? 1 : 0))
            }
        }
    }

    // -------------------------------------------------------------------------

    function cardinalDirection(azimuth) {
        var az = (azimuth + 360) % 360;

        if (az > 348.75 || az <= 11.25) {
            return qsTr("N");
        } else if (az >  11.25 && az <=  33.75) {
                return qsTr("NNE");
        } else if (az >  33.75 && az <=  56.25) {
                return qsTr("NE");
        } else if (az >  56.25 && az <=  78.75) {
                return qsTr("ENE");
        } else if (az >  78.75 && az <= 101.25) {
                return qsTr("E");
        } else if (az > 101.25 && az <= 123.75) {
                return qsTr("ESE");
        } else if (az > 123.75 && az <= 146.25) {
                return qsTr("SE");
        } else if (az > 146.25 && az <= 168.75) {
                return qsTr("SSE");
        } else if (az > 168.75 && az <= 191.25) {
                return qsTr("S");
        } else if (az > 191.25 && az <= 213.75) {
                return qsTr("SSW");
        } else if (az > 213.75 && az <= 236.25) {
                return qsTr("SW");
        } else if (az > 236.25 && az <= 258.75) {
                return qsTr("WSW");
        } else if (az > 258.75 && az <= 281.25) {
                return qsTr("W");
        } else if (az > 281.25 && az <= 303.75) {
                return qsTr("WNW");
        } else if (az > 303.75 && az <= 326.25) {
                return qsTr("NW");
        } else if (az > 326.25 && az <= 348.75) {
                return qsTr("NNW");
        }

        return "";
    }

    // -------------------------------------------------------------------------

    function selectBackCamera() {
        var cameras = QtMultimedia.availableCameras;

        for (var i = 0; i < cameras.length; i++) {
            var cameraInfo = cameras[i];

            // console.log("cameraInfo:", i, JSON.stringify(cameraInfo, undefined, 2));

            var displayName = cameraInfo.displayName.toLowerCase();
            var deviceId = cameraInfo.deviceId.toLowerCase();

            if (cameraInfo.position === Camera.BackFace ||
                    displayName.indexOf("rear") >= 0 ||
                    displayName.indexOf("back") >= 0 ||
                    deviceId.indexOf("rear") >= 0 ||
                    deviceId.indexOf("back") >= 0) {
                camera.deviceId = cameraInfo.deviceId;

                break;
            }
        }
    }
}
