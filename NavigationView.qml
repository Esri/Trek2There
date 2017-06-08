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
import QtMultimedia 5.5
import QtSensors 5.5

import ArcGIS.AppFramework 1.0

import "js/MathLib.js" as MathLib

//------------------------------------------------------------------------------

Item {

    id: navigationView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool navigating: false
    property bool arrivedAtDestination: false
    property bool autohideToolbar: true
    property bool noPositionSource: false
    property bool showHUD: false
    property bool stopUsingCompassForNavigation: currentSpeed > maximumSpeedForCompass && useCompass
    property double maximumSpeedForCompass: 1.2
    property double currentSpeed: 0.0
    property double currentDistance: 0.0
    property double currentDegreesOffCourse: 0
    property int currentAccuracy: 0
    property int currentAccuracyInUnits: 0
    property int sideMargin: 14 * AppFramework.displayScaleFactor

    signal arrived()
    signal reset()
    signal startNavigation()
    signal pauseNavigation()
    signal endNavigation()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        sensors.startPositionSource();
        if (useCompass){
            sensors.startCompass();
        }

        if (requestedDestination !== null) {
            startNavigation();
        }
    }

    //--------------------------------------------------------------------------

    onStopUsingCompassForNavigationChanged: {
        if (stopUsingCompassForNavigation) {
            statusMessage.message = qsTr("Using GPS");
            statusMessage.show();
            sensors.stopCompass();
        }
        else {
            statusMessage.message = qsTr("Using Compass");
            statusMessage.show();
            sensors.startCompass();
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: appFrame
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
        Accessible.role: Accessible.Pane

        MouseArea{
            id: viewTouchArea
            anchors.fill: parent
            enabled: autohideToolbar ? true : false

            onClicked: {
                if(toolbar.opacity === 0){
                    toolbar.opacity = 1;
                    toolbar.enabled = true;
                    hideToolbar.start();
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

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                Accessible.role: Accessible.Pane

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    //----------------------------------------------------------

                    Rectangle {
                        id:statusMessageContianer
                        Layout.fillWidth: true
                        Layout.preferredHeight: sf(40)
                        Layout.rightMargin: sf(10)
                        Layout.leftMargin: sf(10)
                        Layout.topMargin: sf(10)
                        visible: true
                        color:"transparent"
                        Accessible.role: Accessible.Pane

                        RowLayout{
                            anchors.fill: parent

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                StatusIndicator{
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

                            Rectangle{
                                id: locationAccuracyContainer
                                Layout.preferredWidth: sf(30)
                                Layout.leftMargin: sf(10)
                                Layout.fillHeight: true
                                //visible: !statusMessage.visible
                                color: "transparent"

                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("Location Accuracy Indicator")
                                Accessible.description: qsTr("Location accuracy is denoted on a scale of 1 to 5, with 1 being lowest and 5 being highest. Current location accuracy is rated %1".arg(currentAccuracy))

                                ColumnLayout{
                                    anchors.fill: parent

                                    Rectangle{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"

                                        Text{
                                            id: locationAccuracyIndicator
                                            text: currentAccuracy > 0 ? icons.getIconByName("accuracy" + currentAccuracy.toString()) : ""
                                            color: buttonTextColor
                                                /*(function(accuracy){
                                                var color;
                                                switch(accuracy){
                                                    case 4:
                                                        color = "green";
                                                        break;
                                                    case 3:
                                                        color = "orange";
                                                        break;
                                                    case 2:
                                                        color = "darkorange";
                                                        break;
                                                    case 1:
                                                        color = "red";
                                                        break;
                                                    case 0:
                                                        color = "#aaa";
                                                        break;
                                                    default:
                                                        color = "#aaa;"
                                                        break;
                                                }
                                                return color;

                                            })(currentAccuracy)*/
                                            opacity: 1
                                            anchors.centerIn: parent
                                            font.family: icons.name
                                            font.pointSize: 24
                                            visible: currentAccuracy > 0
                                            z: locationAccuracyBaseline.z + 1
                                            Accessible.ignored: true
                                        }

                                        Text{
                                            id: locationAccuracyBaseline
                                            text: icons.accuracy_indicator
                                            color: currentAccuracy <= 0 ? "#aaa" : buttonTextColor
                                            opacity: .4
                                            anchors.centerIn: parent
                                            font.family: icons.name
                                            font.pointSize: 24
                                            Accessible.ignored: true
                                            z:100
                                        }
                                    }

                                    Rectangle{
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: sf(15)
                                        color: "transparent"
                                        Text{
                                            id: accuracyInUnits
                                            text: currentAccuracy > 0 ? "<p>&plusmn;%1%2</p>".arg(currentAccuracyInUnits.toString()).arg(usesMetric ? "m" : "ft") : "----"
                                            color: currentAccuracy <= 0 ? "#aaa" : buttonTextColor
                                            font.pointSize: 10
                                            opacity: currentAccuracy > 0 ? 1 : .4
                                            anchors.centerIn: parent
                                            textFormat: Text.RichText

                                            Accessible.role: Accessible.Indicator
                                            Accessible.name: qsTr("Accuracy in units is: %1".arg(text))
                                            Accessible.description: qsTr("This denotes the current location accuracy in units rounded upward to the nearest %1".arg(usesMetric ? "meter" : "foot"))
                                        }
                                    }

                                }
                            }
                        }
                    }

                   // DIRECTION ARROW //////////////////////////////////////////

                    Rectangle {
                        id: directionUI
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        property int imageScaleFactor: sf(40)
                        Accessible.role: Accessible.Pane

                        Rectangle{
                            id: noDestinationSet
                            anchors.fill: parent
                            anchors.leftMargin: sideMargin
                            anchors.rightMargin: sideMargin
                            z: 100
                            visible: (requestedDestination === null) ? true : false
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            Rectangle{
                                anchors.centerIn: parent
                                height: sf(80)
                                width: parent.width
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                Accessible.role: Accessible.Pane

                                ColumnLayout{
                                    anchors.fill: parent
                                    spacing: 0
                                    Accessible.role: Accessible.Pane

                                    Text{
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

                                    Text{
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

                        //------------------------------------------------------

                        Rectangle{
                            anchors.fill: parent
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            z: 99
                            Accessible.role: Accessible.Pane



                            Image{
                                id: directionOfTravel
                                anchors.centerIn: parent
                                height: isLandscape ? parent.height : parent.height - directionUI.imageScaleFactor
                                width: isLandscape ? parent.width : parent.width - directionUI.imageScaleFactor
                                source: "images/direction_of_travel_circle.png"
                                fillMode: Image.PreserveAspectFit
                                visible: useDirectionOfTravelCircle && !noPositionSource
                                Accessible.ignored: true
                            }

                            Image{
                                id: directionArrow
                                anchors.centerIn: parent
                                source: !nightMode ? "images/arrow_day.png" : "images/arrow_night.png"
                                width: isLandscape ? parent.width - directionUI.imageScaleFactor : parent.width - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                height: isLandscape ? parent.height - directionUI.imageScaleFactor : parent.height - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                fillMode: Image.PreserveAspectFit
                                rotation: currentDegreesOffCourse
                                opacity: 1
                                visible: !noPositionSource
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("Direction of travel is: %1".arg(rotation.toString()))
                                Accessible.description: qsTr("This arrow points toward the direction the user should travel. The degree is based off of the top of the device being the current bearing of travel.")
                                Accessible.ignored: arrivedAtDestination
                            }

                            Image{
                                id: arrivedIcon
                                anchors.centerIn: parent
                                source: !nightMode ? "images/map_pin_day.png" : "images/map_pin_night.png"
                                width: isLandscape ? parent.width - directionUI.imageScaleFactor : parent.width - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                height: isLandscape ? parent.height - directionUI.imageScaleFactor : parent.height - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                fillMode: Image.PreserveAspectFit
                                rotation: 0
                                visible: false
                                Accessible.role: Accessible.AlertMessage
                                Accessible.name: qsTr("Arrived at destination")
                                Accessible.description: qsTr("You have arrived at your destination")
                                Accessible.ignored: navigating
                            }

                            Image{
                                id: noSignalIndicator
                                anchors.centerIn: parent
                                height: isLandscape ? parent.height : parent.height - directionUI.imageScaleFactor
                                width: isLandscape ? parent.width : parent.width - directionUI.imageScaleFactor
                                source: "images/no_signal.png"
                                visible: noPositionSource && !arrivedAtDestination
                                fillMode: Image.PreserveAspectFit
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("There is no signal")
                            }
                        }
                        //------------------------------------------------------
                    }
                }
            }

            // DISTANCE READOUT ////////////////////////////////////////////////

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(100)
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane

                Text {
                    id: distanceReadout
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: displayDistance(currentDistance.toString())
                    font.pointSize: extraLargeFontSize
                    font.weight: Font.Light
                    fontSizeMode: Text.Fit
                    minimumPointSize: largeFontSize
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    visible: requestedDestination !== null
                    Accessible.role: Accessible.Indicator
                    Accessible.name: text
                    Accessible.description: qsTr("This value is the distance remaining between you and the destination")
                }
            }

            // UTILITY | SETTINGS //////////////////////////////////////////////

            Rectangle {
                id: toolbar
                Layout.fillWidth: true
                Layout.preferredHeight: sf(50)
                color: "transparent"
                opacity: 1
                Accessible.role: Accessible.Pane
                Accessible.name: qsTr("Toolbar")
                Accessible.description: qsTr("This toolbar contains the settings button, the end navigation button and the day night mode switch button")

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: sf(50)
                        color: "transparent"
                        Accessible.role: Accessible.Pane

                        Button{
                            id: settingsButton
                            anchors.fill: parent
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Settings")

                            background: Rectangle{
                                color: "transparent"
                                anchors.fill: parent
                            }

                            Image{
                                id: settingsButtonIcon
                                anchors.centerIn: parent
                                height: parent.height - sf(24)
                                fillMode: Image.PreserveAspectFit
                                source: "images/settings.png"
                            }

                            onClicked:{
                                if(navigating === false){
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

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        Accessible.role: Accessible.Pane

                        Button{
                            id: endNavigationButton
                            anchors.fill: parent
                            visible: false
                            enabled: false

                            background: Rectangle{
                                anchors.fill: parent
                                anchors.bottomMargin: sf(5)
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                border.width: sf(1)
                                border.color: !nightMode ? dayModeSettings.buttonBorder : nightModeSettings.buttonBorder
                                radius: sf(5)

                            }

                            Text{
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                anchors.rightMargin: sf(15)
                                text: qsTr("End")
                                color: buttonTextColor
                            }

                            onClicked: {
                                endNavigation();
                                if(applicationCallback !== ""){
                                    callingApplication = "";
                                    Qt.openUrlExternally(applicationCallback);
                                    applicationCallback = "";
                                }
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("End navigation")
                            Accessible.description: qsTr("Click this button to end navigation and reset the user interface. You will be taken back to the calling application if appropriate.")
                            Accessible.onPressAction: {
                                if(visible && enabled){
                                    clicked(null);
                                }
                            }
                        }
                    }

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: sf(50)
                        color: "transparent"
                        Accessible.role: Accessible.Pane

                        Button{
                            id: viewModeButton
                            anchors.fill: parent
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("View Mode")

                            background: Rectangle{
                                color: "transparent"
                                anchors.fill: parent
                            }

                            Image{
                                id: viewModeButtonIcon
                                anchors.centerIn: parent
                                height: parent.height - sf(26)
                                fillMode: Image.PreserveAspectFit
                                source: "images/contrast.png"
                            }

                            onClicked:{
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
            //------------------------------------------------------------------
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onArrived: {
        arrivedAtDestination = true;
        navigating = false;
        sensors.stopPositionSource();
        directionArrow.visible = false
        arrivedIcon.visible = true
        distanceReadout.text = qsTr("Arrived");
        try{
            appMetrics.trackEvent("Arrived at destination.");
        }
        catch(e){
            appMetrics.reportError(e, "onArrived");
        }
    }

    //--------------------------------------------------------------------------

    onReset: {
        console.log('reseting navigation')

        navigating = false;
        sensors.stopPositionSource();
        statusMessage.hide();

        arrivedAtDestination = false;
        arrivedIcon.visible = false

        directionArrow.visible = true;
        directionArrow.rotation = 0;
        directionArrow.opacity = 1;

        currentDistance = 0.0;
        distanceReadout.text = displayDistance(currentDistance.toString());

        currentAccuracy = 0;
        currentAccuracyInUnits = 0;

        if(autohideToolbar === true){
            if(hideToolbar.running){
                hideToolbar.stop();
            }
            if(fadeToolbar.running){
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
        sensors.startPositionSource();
        sensors.positionSource.update();
        currentPosition.destinationCoordinate = requestedDestination;
        sensors.positionSource.update();
        endNavigationButton.visible = true;
        endNavigationButton.enabled = true;

        if(autohideToolbar === true){
            hideToolbar.start();
        }

        try{
            appMetrics.startSession();
            if(callingApplication !== null && callingApplication !== ""){
                appMetrics.trackEvent("App called from: " + callingApplication);
            }
        }
        catch(e){
            appMetrics.reportError(e, "onStartNavigation");
        }

        if(logTreks){
            trekLogger.startRecordingTrek();
        }
    }

    //--------------------------------------------------------------------------

    onPauseNavigation:{
    }

    //--------------------------------------------------------------------------

    onEndNavigation:{
        console.log('ending navigation')
        reset();
        navigating = false;
        endNavigationButton.visible = false;
        endNavigationButton.enabled = false;
        requestedDestination = null;

        if(logTreks){
            trekLogger.stopRecordingTrek();
        }

        try{
            if(arrivedAtDestination === false){
                appMetrics.trackEvent("Ended navigation without arrival.");
            }
        }
        catch(e){
            appMetrics.reportError(e, "onEndNavigation");
        }

    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    CurrentPosition {
        id: currentPosition

        onDistanceToDestinationChanged: {
            if(navigating === true){
                distanceReadout.text = displayDistance(distanceToDestination);
            }
        }

        onDegreesOffCourseChanged: {
            if(degreesOffCourse === NaN || degreesOffCourse === 0){
                noPositionSource = true;
                directionArrow.opacity = 0.2;
            }else{
                noPositionSource = false;
                directionArrow.opacity = 1;
                directionArrow.rotation = degreesOffCourse;
            }
        }

        onAtDestination: {
            if(navigating===true){
                arrived();
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections{
        target: app
        onRequestedDestinationChanged: {
            console.log(requestedDestination);
            if (requestedDestination !== null) {
                viewData.itemCoordinate = requestedDestination;
                startNavigation();
            }
        }

        onUseCompassChanged:{
            if (useCompass) {
                sensors.startCompass();
            }
            else {
                sensors.stopCompass();
            }
        }

        onUseHUDChanged: {
            if(!useHUD){
                //camera.stop();
            }
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
        id:fadeToolbar
        from: 1
        to: 0
        duration: 1000
        property: "opacity"
        running: false
        easing.type: Easing.Linear
        target: toolbar

        onStopped: {
            toolbar.enabled = false;
            if(hideToolbar.running===true){
                hideToolbar.stop();
            }
        }
    }

    //--------------------------------------------------------------------------

    HUDSensors {
        id: sensors

        azimuthFilterType: 0 // 0=rounding 1=smoothing
        azimuthRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
        azimuthFilterLength: 10
        attitudeFilterType: 1 // 0=rounding 1=smoothing
        attitudeRounding: 2  // Nearest degree >> 2=0.5, 3=0.33, 4=0.25 ... 10=0.1
        attitudeFilterLength: 25
        magneticDeclination: 0.0

        onSensorPositionChanged: {
                if (sensors.position.coordinate.isValid) {
                    if (position.latitudeValid && position.longitudeValid) {
                        currentPosition.position = sensors.position;
                        viewData.observerCoordinate = QtPositioning.coordinate(sensors.position.coordinate.latitude, sensors.position.coordinate.longitude, sensors.position.coordinate.altitude);
                    }
                }

                if (sensors.position.horizontalAccuracyValid) {
                    var accuracy = sensors.position.horizontalAccuracy;
                    if(accuracy < 10){
                        currentAccuracy = 4;
                    }
                    else if(accuracy > 11 && accuracy < 55){
                        currentAccuracy = 3;
                    }
                    else if(accuracy > 56 && accuracy < 100){
                        currentAccuracy = 2;
                    }
                    else if(accuracy >= 100){
                        currentAccuracy = 1;
                    }
                    else{
                        currentAccuracy = 0;
                    }

                    currentAccuracyInUnits = usesMetric ? Math.ceil(accuracy) : Math.ceil(accuracy * 3.28084)
                }

                if (sensors.position.speedValid) {
                    currentSpeed = sensors.position.speed;
                }

               if(requestedDestination !== null){
                    /*
                        TODO: On some Android devices position.directionValid must return
                        true so the statusMessage isn't shown when navigation first starts
                        in order to inform the user to move. This isn't an issue on iOS.
                        May need to evaluate reset() method that hides the status
                        message as well as the startNavigation method as well to fix this.
                    */
                    if (sensors.position.directionValid){
                        noPositionSource = false;
                        statusMessage.hide();
                    }
                    else{
                        noPositionSource = true;
                        directionArrow.opacity = 0.2;
                        statusMessage.show();
                    }
               }
        }

        onPositionChanged: {}

        onAzimuthFromTrueNorthChanged: updateBearing()

        onPitchAngleChanged: updatePitch()

        onRollAngleChanged: updateRoll()

        onOrientationChanged: {
            showHUD = (orientation !== OrientationReading.FaceUp && orientation !== OrientationReading.FaceDown && orientation !== OrientationReading.Undefined);
        }

        function updatePosition() {
            if (position.latitudeValid && position.longitudeValid) {
                //viewData.setPosition(position, currentPosition.arrivalThresholdInMeters);
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

    }

    //    PositionSource {
    //        id: positionSource

    //        onPositionChanged: {
    //            if (position.coordinate.isValid === true) {
    //                console.log("lat: %1, long:%2".arg(position.coordinate.latitude).arg(position.coordinate.longitude));
    //                currentPosition.position = position;
    //            }

    //            if(position.horizontalAccuracyValid){
    //                var accuracy = position.horizontalAccuracy;
    //                if(accuracy < 10){
    //                    currentAccuracy = 4;
    //                }
    //                else if(accuracy > 11 && accuracy < 55){
    //                    currentAccuracy = 3;
    //                }
    //                else if(accuracy > 56 && accuracy < 100){
    //                    currentAccuracy = 2;
    //                }
    //                else if(accuracy >= 100){
    //                    currentAccuracy = 1;
    //                }
    //                else{
    //                    currentAccuracy = 0;
    //                }

    //                currentAccuracyInUnits = usesMetric ? Math.ceil(accuracy) : Math.ceil(accuracy * 3.28084)
    //            }

    //           if(requestedDestination !== null){
    //                /*
    //                    TODO: On some Android devices position.directionValid must return
    //                    true so the statusMessage isn't shown when navigation first starts
    //                    in order to inform the user to move. This isn't an issue on iOS.
    //                    May need to evaluate reset() method that hides the status
    //                    message as well as the startNavigation method as well to fix this.
    //                */
    //                if (position.directionValid){
    //                    noPositionSource = false;
    //                    statusMessage.hide();
    //                }
    //                else{
    //                    noPositionSource = true;
    //                    directionArrow.opacity = 0.2;
    //                    statusMessage.show();
    //                }
    //           }
    //        }

    //        onSourceErrorChanged: {
    //        }
    //    }

    // METHODS /////////////////////////////////////////////////////////////////

    function displayDistance(distance) {

        if(usesMetric === false){
            var distanceFt = distance * 3.28084;
            if (distanceFt < 1000) {
                return "%1 ft".arg(Math.round(distanceFt).toLocaleString(locale, "f", 0))
            } else {
                var distanceMiles = distance * 0.000621371;
                return "%1 mi".arg((Math.round(distanceMiles * 10) / 10).toLocaleString(locale, "f", distanceMiles < 10 ? 1 : 0))
            }
        }
        else{
            if (distance < 1000) {
                return "%1 m".arg(Math.round(distance).toLocaleString(locale, "f", 0))
            } else {
                var distanceKm = distance / 1000;
                return "%1 km".arg((Math.round(distanceKm * 10) / 10).toLocaleString(locale, "f", distanceKm < 10 ? 1 : 0))
            }
        }
    }
}

