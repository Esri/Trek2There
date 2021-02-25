/* Copyright 2021 Esri
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

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0

import "../controls"
import "../GNSSPlugin"
import "../GNSSPlugin/GNSSManager"

Item {
    id: settingsView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property GNSSManager gnssManager
    property GNSSSettingsPages gnssSettingsPages

    property var distanceFormats: ["Decimal degrees", "Degrees, minutes, seconds", "Degrees, decimal minutes", "UTM (WGS84)", "MGRS"]

    property var coordinateInfo: Coordinate.convert(requestedDestination, "dd" , { precision: 8 } ).dd
    property var latitude: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.latitudeText ? coordinateInfo.latitudeText : ""
    property var longitude: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.longitudeText ? coordinateInfo.longitudeText : ""
    property var easting: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.easting ? (Math.round(coordinateInfo.easting*1000)/1000).toFixed(3) : ""
    property var northing: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.northing ? (Math.round(coordinateInfo.northing*1000)/1000).toFixed(3) : ""
    property var utmZone: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.zone && coordinateInfo.band ? coordinateInfo.zone + coordinateInfo.band : ""
    property var gridReference: requestedDestination && requestedDestination.isValid && coordinateInfo && coordinateInfo.text ? coordinateInfo.text : ""

    readonly property GNSSSettings gnssSettings: gnssManager.gnssSettings
    readonly property bool isConnecting: gnssManager.isConnecting
    readonly property bool isConnected: gnssManager.isConnected

    readonly property var connectionStateColor: isConnecting ? "green" : isConnected ? buttonTextColor : "red"
    readonly property var connectionStateText:  isConnecting ? qsTr("(Connecting)") : isConnected ? qsTr("(Connected)") : qsTr("(Disconnected)")

    property bool initialized

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        gnssManager.stayConnected = false;
        initialized = true;
    }

    StackView.onDeactivating: {
        initialized = false;
        gnssManager.stayConnected = true;
    }

    //--------------------------------------------------------------------------

    Connections {
        target: app

        function onRequestedDestinationChanged() {
            if (app.requestedDestination && app.requestedDestination.isValid) {
                setCoordinateInfo(app.coordinateFormat);
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
                                font.pixelSize: largeFontSize
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
                                    font.pixelSize: baseFontSize
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

                                    font.pixelSize: baseFontSize

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

                                    currentIndex: coordinateFormat

                                    onCurrentIndexChanged: {
                                        coordinateFormat = currentIndex;
                                        if (requestedDestination && requestedDestination.isValid) {
                                            setCoordinateInfo(coordinateFormat);
                                        }
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        SettingsCoordinateField {
                            id: latitudeField

                            visible: coordinateFormat < 3

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

                            visible: coordinateFormat < 3

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

                            visible: coordinateFormat == 3

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

                            visible: coordinateFormat == 3

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

                            visible: coordinateFormat == 3

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

                            visible: coordinateFormat == 4

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
                                font.pixelSize: largeFontSize
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

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            SettingsRadioButton {
                                id: metricChecked

                                anchors.fill: parent
                                anchors.leftMargin: sideMargin

                                text: "Metric"
                                checked: usesMetric

                                onCheckedChanged: {
                                    if (initialized && checked) {
                                        usesMetric = true;
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            SettingsRadioButton {
                                id: imperialChecked

                                anchors.fill: parent
                                anchors.leftMargin: sideMargin

                                text: "Imperial"
                                checked: !usesMetric

                                onCheckedChanged: {
                                    if (initialized && checked) {
                                        usesMetric = false;
                                    }
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
                                text: qsTr("LOCATION PROVIDER")
                                font.pixelSize: largeFontSize
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground

                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Choose between integrated or external location providers")
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            Button {
                                id: externalDeviceButton

                                anchors.fill: parent

                                contentItem: Rectangle {
                                    anchors.fill: parent
                                    anchors.leftMargin: sideMargin
                                    anchors.rightMargin: sideMargin

                                    color: !nightMode ? (externalDeviceButton.down ? dayModeSettings.secondaryBackground : dayModeSettings.background) : (externalDeviceButton.down ? nightModeSettings.secondaryBackground : nightModeSettings.background)

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: sf(10)

                                        Text {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            text: (gnssSettings.lastUsedDeviceLabel > "" ? gnssSettings.lastUsedDeviceLabel : gnssSettings.lastUsedDeviceName) + " " + connectionStateText
                                            font.pixelSize: baseFontSize
                                            color: connectionStateColor
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignRight

                                            text: "Change"
                                            font.pixelSize: baseFontSize
                                            color: connectionStateColor
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }

                                background: Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    color: !nightMode ? (externalDeviceButton.down ? dayModeSettings.secondaryBackground : dayModeSettings.background) : (externalDeviceButton.down ? nightModeSettings.secondaryBackground : nightModeSettings.background)
                                }

                                onClicked: {
                                    gnssSettingsPages.showLocationSettings(stackView);
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
                                font.pixelSize: largeFontSize
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Turn experimental features on or off. This will enable compass assisted navigation for walking and provide a visual marker on the head up display that denotes your destination.")
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
                                anchors.topMargin: sf(5)

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
                                            return "melbourneteam@esri.com";
                                        }
                                    })()

                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.leftMargin: sideMargin
                                    Layout.rightMargin: sideMargin
                                    text: qsTr("Esri Labs encourages users to use these features and provide feedback. Please <a href='mailto:%1'>email us</a> with your feedback.<br>").arg(feedbackEmail)
                                    font.pixelSize: baseFontSize
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    opacity: .8
                                    Accessible.ignored: true
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

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            SettingsCheckBox {
                                id: compassCheckBox

                                anchors.fill: parent
                                anchors.leftMargin: sideMargin

                                text: qsTr("Use compass")

                                checked: useCompass ? true : false
                                onCheckedChanged: {
                                    if (initialized) {
                                        useCompass = !useCompass ? true : false;
                                    }
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: xFeaturesText1.text
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: xFeaturesText1.contentHeight
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin

                                Text {
                                    id: xFeaturesText1

                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.leftMargin: sf(20) + sideMargin
                                    text: qsTr("Use compass to establish bearing to target if stationary.")
                                    font.pixelSize: baseFontSize
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    opacity: .8
                                    Accessible.ignored: true
                                    wrapMode: Text.Wrap
                                    textFormat: Text.StyledText
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            SettingsCheckBox {
                                id: hudCheckBox

                                anchors.fill: parent
                                anchors.leftMargin: sideMargin

                                text: qsTr("Use augmented reality display")

                                checked: useHUD ? true : false
                                onCheckedChanged: {
                                    if (initialized) {
                                        useHUD = !useHUD ? true : false;
                                    }
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: xFeaturesText2.text
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: xFeaturesText2.contentHeight + sf(5)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin

                                Text {
                                    id: xFeaturesText2

                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.leftMargin: sf(20) + sideMargin
                                    text: qsTr("Activate the augmented reality display and show a location pin if the device is held upright.")
                                    font.pixelSize: baseFontSize
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    opacity: .8
                                    Accessible.ignored: true
                                    wrapMode: Text.Wrap
                                    textFormat: Text.StyledText
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

        switch (coordinateFormat) {
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

            setCoordinateInfo(coordinateFormat);
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
