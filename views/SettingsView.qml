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
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtPositioning 5.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0
import ArcGIS.AppFramework.Networking 1.0

import "../controls"

Item {
    id: settingsView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property var distanceFormats: ["Decimal degrees", "Degrees, minutes, seconds", "Degrees, decimal minutes", "UTM (WGS84)", "MGRS"]

    property var coordinateInfo: Coordinate.convert(requestedDestination, "dd" , { precision: 8 } ).dd
    property var latitude: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.latitudeText ? coordinateInfo.latitudeText : ""
    property var longitude: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.longitudeText ? coordinateInfo.longitudeText : ""
    property var easting: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.easting ? (Math.round(coordinateInfo.easting*1000)/1000).toFixed(3) : ""
    property var northing: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.northing ? (Math.round(coordinateInfo.northing*1000)/1000).toFixed(3) : ""
    property var utmZone: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.zone && coordinateInfo.band ? coordinateInfo.zone + coordinateInfo.band : ""
    property var gridReference: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.text ? coordinateInfo.text : ""

    property bool initialized

    StackView.onActivating: {
        initialized = true;

        if (!isConnecting && !isConnected && externalChecked.checked) {
            discoveryAgent.start();
        }
    }

    StackView.onDeactivating: {
        initialized = false;
    }

    Connections {
        target: app

        onRequestedDestinationChanged: {
            if (requestedDestination && requestedDestination.isValid) {
                setCoordinateInfo(currentDistanceFormat);
            }
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
        Accessible.role: Accessible.Pane

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            SettingsHeader {
                text: qsTr("Settings")
            }

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                Accessible.role: Accessible.Pane

                Flickable {
                    width: parent.width
                    height: parent.height
                    contentHeight: contentItem.children[0].childrenRect.height
                    contentWidth: parent.width
                    interactive: true
                    flickableDirection: Flickable.VerticalFlick
                    clip: true
                    Accessible.role: Accessible.Pane

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:0
                        Accessible.role: Accessible.Pane

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.bottomMargin: sf(5)
                            Layout.fillWidth: true
                            color: "transparent"
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("DESTINATION")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Enter your destination latitude and longitude below and then hit the back button to start navigation.")
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.bottomMargin: sf(2)
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0
                                Accessible.role: Accessible.Pane

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: sf(120)
                                    text: qsTr("Format")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    Accessible.role: Accessible.Heading
                                    Accessible.name: text
                                }

                                ComboBox {
                                    id: coordBox

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Accessible.role: Accessible.ComboBox
                                    Accessible.name: qsTr("Change coordinate format")
                                    Accessible.description: qsTr("Change the format of the coordiante entry. For example decimal degrees to MGRS.")

                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                    }

                                    contentItem: Text {
                                        leftPadding: sf(12)
                                        rightPadding: coordBox.indicator.width + coordBox.spacing

                                        text: coordBox.displayText
                                        font: coordBox.font
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    delegate: ItemDelegate {
                                        width: coordBox.width

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: highlighted ? !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground : !nightMode ? dayModeSettings.background : nightModeSettings.background
                                        }

                                        contentItem: Text {
                                            text: modelData
                                            font: coordBox.font
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignLeft
                                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        }

                                        highlighted: coordBox.highlightedIndex === index
                                    }

                                    model: distanceFormats

                                    currentIndex: currentDistanceFormat

                                    onCurrentIndexChanged: {
                                        currentDistanceFormat = currentIndex;
                                        if (requestedDestination && requestedDestination.isValid) {
                                            setCoordinateInfo(currentDistanceFormat);
                                        }
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: latitudeField

                            visible: currentDistanceFormat < 3

                            label: qsTr("Latitude")
                            text: (requestedDestination === null) ? "" : latitude
                            placeholderText: qsTr("Enter latitude")

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter latitude")
                            Accessible.description: qsTr("Enter the latitude of your desired destination here.")
                            Accessible.editable: true
                            Accessible.focusable: true

                            onEditingFinished: invalid = !validateCoordinates()
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: longitudeField

                            visible: currentDistanceFormat < 3

                            label: qsTr("Longitude")
                            text: (requestedDestination === null) ? "" : longitude
                            placeholderText: qsTr("Enter longitude")

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter longitude")
                            Accessible.description: qsTr("Enter the longitude of your desired destination here.")
                            Accessible.editable: true
                            Accessible.focusable: true

                            onEditingFinished: invalid = !validateCoordinates()
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: utmZoneField

                            visible: currentDistanceFormat == 3

                            label: qsTr("UTM Zone")
                            text: (requestedDestination === null) ? "" : utmZone
                            placeholderText: qsTr("Enter UTM Zone")

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter UTM Zone")
                            Accessible.description: qsTr("Enter the UTM zone of your desired destination here.")
                            Accessible.editable: true
                            Accessible.focusable: true

                            onEditingFinished: invalid = !validateCoordinates()
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: eastingField

                            visible: currentDistanceFormat == 3

                            label: qsTr("Easting")
                            text: (requestedDestination === null) ? "" : easting
                            placeholderText: qsTr("Enter easting")

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter easting")
                            Accessible.description: qsTr("Enter the easting of your desired destination here.")
                            Accessible.editable: true
                            Accessible.focusable: true

                            onEditingFinished: invalid = !validateCoordinates()
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: northingField

                            visible: currentDistanceFormat == 3

                            label: qsTr("Northing")
                            text: (requestedDestination === null) ? "" : northing
                            placeholderText: qsTr("Enter northing")

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter northing")
                            Accessible.description: qsTr("Enter the northing of your desired destination here.")
                            Accessible.editable: true
                            Accessible.focusable: true

                            onEditingFinished: invalid = !validateCoordinates()
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: gridReferenceField

                            visible: currentDistanceFormat == 4

                            label: qsTr("Grid Reference")
                            text: (requestedDestination === null) ? "" : gridReference
                            placeholderText: qsTr("Enter grid reference")

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter MGRS grid reference")
                            Accessible.description: qsTr("Enter the MGRS grid reference of your desired destination here.")
                            Accessible.editable: true
                            Accessible.focusable: true

                            onEditingFinished: invalid = !validateCoordinates()
                        }

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.topMargin: sf(8)
                            Layout.bottomMargin: sf(5)
                            color: "transparent"
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("DISTANCE UNIT")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Select the desired unit of measure from the following choices.")
                            }
                        }

                        //------------------------------------------------------

                        ButtonGroup {
                            id: distanceMeasurementGroup

                            buttons: [metricChecked.radioButton, imperialChecked.radioButton]
                        }

                        //------------------------------------------------------

                        SettingsRadioButton {
                            id: metricChecked

                            text: "Metric"
                            checked: usesMetric

                            onCheckedChanged: {
                                if (initialized && checked) {
                                    usesMetric = true;
                                }
                            }
                        }

                        //------------------------------------------------------

                        SettingsRadioButton {
                            id: imperialChecked

                            text: "Imperial"
                            checked: !usesMetric

                            onCheckedChanged: {
                                if (initialized && checked) {
                                    usesMetric = false;
                                }
                            }
                        }

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.topMargin: sf(8)
                            Layout.bottomMargin: sf(5)
                            color: "transparent"
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("POSITION SOURCE")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Choose between the device internal or an external position source")
                            }
                        }

                        //------------------------------------------------------

                        ButtonGroup {
                            id: gpsReceiverGroup

                            buttons: [internalChecked.radioButton, externalChecked.radioButton]
                        }

                        //------------------------------------------------------

                        SettingsRadioButton {
                            id: internalChecked

                            text: "Use built-in location sensor"
                            checked: useInternalGPS

                            onCheckedChanged: {
                                if (initialized && checked) {
                                    sources.disconnect();
                                    app.discoveryAgent.stop();
                                }
                            }
                        }

                        //------------------------------------------------------

                        RowLayout {
                            spacing: 0

                            SettingsRadioButton {
                                id: externalChecked

                                text: "Use external receiver"
                                checked: !useInternalGPS

                                onCheckedChanged: {
                                    if (initialized && checked) {
                                        if (storedDevice > "") {
                                            if (currentDevice && currentDevice.name === storedDevice) {
                                                sources.deviceSelected(currentDevice);
                                            } else {
                                                discoveryAgent.start();
                                            }
                                        } else if (!isConnecting && !isConnected) {
                                            mainStackView.push(devicesView);
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(30)
                                anchors.bottom: parent.bottom
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                BusyIndicator {
                                    id: discoveryIndicator

                                    anchors.fill: parent

                                    running: app.isConnecting || discoveryAgent.running && !app.isConnected
                                }

                                ColorOverlay {
                                    anchors.fill: discoveryIndicator
                                    source: discoveryIndicator
                                    color: buttonTextColor
                                }
                            }

                            Rectangle {
                                id: discoveryIndicatorRect

                                Layout.fillHeight: true
                                Layout.preferredWidth: sideMargin
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            }
                        }

                        //------------------------------------------------------

                        RowLayout {
                            visible: externalChecked.checked

                            spacing: 0

                            Rectangle {
                                Layout.preferredHeight: sf(50)
                                Layout.fillWidth: true
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                Accessible.role: Accessible.Pane

                                Text {
                                    property string name: useExternalGPS ? (currentDevice ? currentDevice.name : "Unknown") : ((tcpSocket.remoteName && tcpSocket.remotePort) ? tcpSocket.remoteName + ":" + tcpSocket.remotePort : "Unknown")

                                    anchors.fill: parent
                                    color: app.isConnecting ? "green" : !app.isConnected && app.storedDevice > "" && discoveryAgent.running ? "red" : buttonTextColor
                                    text: app.isConnecting ? "Connecting to " + name : app.isConnected ? "Connected to " + name : app.storedDevice > "" && discoveryAgent.running ? "Looking for " + app.storedDevice : qsTr("Not connected")
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: /*radioButton.indicator.width + 2*externalChecked.radioButton.spacing +*/ sideMargin
                                }
                            }

                            Button {
                                id: externalDeviceButton

                                visible: externalChecked.checked

                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(100)
                                anchors.right: parent.right

                                contentItem: Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    text: "Change"
                                    color: app.isConnecting ? "green" : !app.isConnected && app.storedDevice > "" && discoveryAgent.running ? "red" : buttonTextColor
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                background: Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    color: !nightMode ? (externalDeviceButton.down ? dayModeSettings.secondaryBackground : dayModeSettings.background) : (externalDeviceButton.down ? nightModeSettings.secondaryBackground : nightModeSettings.background)
                                }

                                onClicked: {
                                    mainStackView.push(devicesView);
                                }
                            }
                        }

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.topMargin: sf(8)
                            Layout.bottomMargin: sf(5)
                            color: "transparent"
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("EXPERIMENTAL FEATURES")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Turn experimental features on or off. This will enable compass assisted navigation for walking and provide a visual marker on the head up display horizon that denotes yoru destination.")
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: sf(40)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                            Button {
                                anchors.fill: parent
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Item {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: sf(18)
                                        Layout.leftMargin: sideMargin

                                        Rectangle {
                                            width: parent.width
                                            height: width
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: !nightMode ? "#ededed" : "#272727"
                                            border.width: sf(2)
                                            border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                            Image {
                                                anchors.centerIn: parent
                                                width: parent.width - sf(8)
                                                fillMode: Image.PreserveAspectFit
                                                visible: useExperimentalFeatures
                                                source: "../images/checkmark.png"
                                                Accessible.ignored: true
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: sideMargin
                                        text: qsTr("Use experimental features")
                                        verticalAlignment: Text.AlignVCenter
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        Accessible.ignored: true
                                    }
                                }

                                onClicked: {
                                    useExperimentalFeatures = !useExperimentalFeatures ? true : false;
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: qsTr("Use experimental features")
                                Accessible.onPressAction: {
                                    clicked();
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: xFeaturesText.contentHeight
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin

                                Item {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: sf(18)
                                }

                                Text {
                                    id: xFeaturesText

                                    property var feedbackEmail: (function() {
                                        if (Qt.platform.os === "ios") {
                                            return "support+f9c5dcb8b61d48e88b9a784ce59feac2@feedback.hockeyapp.net";
                                        }
                                        else if (Qt.platform.os === "android") {
                                            return "support+244a6f679d574cbab4532849cdbf9e06@feedback.hockeyapp.net";
                                        }
                                        else if (Qt.platform.os === "windows" || Qt.platform.os === "winrt") {
                                            return "support+270310d21ec14a93acf5a41cf1bad33d@feedback.hockeyapp.net";
                                        }
                                        else {
                                            return "jayson_ward@esri.com";
                                        }
                                    })()

                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.bottomMargin: sf(20)
                                    Layout.leftMargin: sideMargin
                                    text: "Current experimental features include use of compass to establish course correction at walking speed and display of location pin on the head up display horizon. Esri Labs encourages users to use these features and provide feedback.<br><br>Please <a href='mailto:%1'>email us</a> with your feedback.<br>".arg(feedbackEmail)
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    opacity: .8
                                    Accessible.ignored: true
                                    font.pointSize: 10
                                    wrapMode: Text.Wrap
                                    textFormat: Text.StyledText
                                    linkColor: "#007ac2"

                                    onLinkActivated: {
                                        console.log(link);
                                        Qt.openUrlExternally(link);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // FUNCTION DEFINITIONS ////////////////////////////////////////////////////

    function validateCoordinates() {
        var valid = true;
        var coordObj = null;

        switch (currentDistanceFormat) {
        case 0: // decimal degrees
        case 1: // degrees, minutes, seconds
        case 2: // degrees, decimal minutes
            if (latitudeField.text > "" && longitudeField.text > "") {
                coordObj = Coordinate.parse(latitudeField.text + " " + longitudeField.text);
            }
            break;
        case 3: // utm
            if (utmZoneField.text > "" && eastingField.text > "" && northingField.text > "") {
                coordObj = Coordinate.parse(utmZoneField.text + " " + eastingField.text + "E " + northingField.text + "N");
            }
            break;
        case 4: // MGRS
            if (gridReferenceField.text > "") {
                coordObj = Coordinate.parse("MGRS " + gridReferenceField.text, { spaces: true });
            }
            break;
        }

        if (coordObj) {
            valid = coordObj.coordinateValid
            if (valid) {
                requestedDestination = coordObj.coordinate;
            }

            setCoordinateInfo(currentDistanceFormat);
        }

        return valid;
    }

    function setCoordinateInfo(index) {
        switch(index) {
        case 0: // decimal degrees
            coordinateInfo = Coordinate.convert(requestedDestination, "dd", { precision: 8 }).dd;
            break;
        case 1: // degrees, minutes, seconds
            coordinateInfo = Coordinate.convert(requestedDestination, "dms", { precision: 4 }).dms;
            break;
        case 2: // degrees, decimal minutes
            coordinateInfo = Coordinate.convert(requestedDestination, "ddm", { precision: 6 }).ddm;
            break;
        case 3: // utm
            // options are ignored for utm
            coordinateInfo = Coordinate.convert(requestedDestination, "utm").utm;
            break;
        case 4: // MGRS
            // "precision" here is in metres, whereas it's the number of decimal places in the above
            coordinateInfo = Coordinate.convert(requestedDestination, "mgrs", { precision: 0.01, spaces: true }).mgrs;
            break;
        }
    }

    //------------------------------------------------------------------
}
