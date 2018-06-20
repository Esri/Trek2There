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

import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

import QtPositioning 5.2 // needed for the call to QtPositioning.coordinate()

// -----------------------------------------------------------------------------

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Positioning 1.0

// -----------------------------------------------------------------------------

import "AppMetrics"
import "IconFont"
import "views"
import "controls"

// -----------------------------------------------------------------------------

App {
    id: app

    width: 480 * AppFramework.displayScaleFactor
    height: 640 * AppFramework.displayScaleFactor

    Accessible.role: Accessible.Window

    // Properties --------------------------------------------------------------

    property alias positionSource: sources.positionSource
    property alias satelliteInfoSource: sources.satelliteInfoSource
    property alias nmeaSource: sources.nmeaSource
    property alias tcpSocket: sources.tcpSocket
    property alias discoveryAgent: sources.discoveryAgent

    property Device currentDevice: sources.currentDevice
    property bool isConnecting: sources.isConnecting
    property bool isConnected: sources.isConnected

    property bool discoverBluetooth: app.settings.boolValue("discoverBluetooth", true)
    property bool discoverSerialPort: app.settings.boolValue("discoverSerialPort", false)
    property string storedDevice: app.settings.value("device", "");
    property string hostname: app.settings.value("hostname", "");
    property int port: settings.numberValue("port", "");
    property int connectionType: app.settings.numberValue("connectionType", sources.eConnectionType.internal);
    property int lastConnectionType: app.settings.numberValue("connectionType", sources.eConnectionType.internal);

    property bool safetyWarningAccepted: app.settings.boolValue("safetyWarningAccepted", false)
    property bool showSafetyWarning: app.settings.boolValue("showSafetyWarning", true)
    property bool listenToClipboard: app.settings.boolValue("listenToClipboard", true)
    property bool logTreks: app.settings.boolValue("logTreks", false)
    property bool nightMode: app.settings.boolValue("nightMode", false)
    property bool usesMetric: app.settings.boolValue("usesMetric", localeIsMetric())
    property bool useCompass: app.settings.boolValue("useCompass", false)
    property bool useHUD: app.settings.boolValue("useHUD", false)
    property int coordinateFormat: app.settings.numberValue("coordinateFormat", 0)
    property string lastLatitude: app.settings.value("lastLatitude", "")
    property string lastLongitude: app.settings.value("lastLongitude", "")

    property RegExpValidator latitudeValidator: RegExpValidator { regExp: /^[-]?90$|^[-]?[1-8][0-9](\.\d{1,})?$|^[-]?[1-9](\.\d{1,})?$/g }
    property RegExpValidator longitudeValidator: RegExpValidator { regExp: /^[-]?180$|^[-]?1[0-7][0-9](\.\d{1,})?$|^[-]?[1-9][0-9](\.\d{1,})?$|^[-]?[1-9](\.\d{1,})?$/g }
    property TrekLogger trekLogger: TrekLogger{}
    property FileFolder fileFolder: FileFolder{ path: AppFramework.userHomePath }
    property string localStoragePath: fileFolder.path + "/ArcGIS/My Treks"

    property var requestedDestination: null
    property var locale: Qt.locale()
    property var openParameters: null
    property string callingApplication: ""
    property string applicationCallback: ""

    property int sideMargin: sf(15)
    property int baseFontSize: 14
    property double largeFontSize: baseFontSize * 1.3
    property double extraLargeFontSize: baseFontSize * 3
    property double smallFontSize: baseFontSize * .8
    property double xSmallFontSize: baseFontSize * .6

    readonly property var nightModeSettings: { "background": "#000", "foreground": "#f8f8f8", "secondaryBackground": "#2c2c2c", "buttonBorder": "#2c2c2c" }
    readonly property var dayModeSettings: { "background": "#f8f8f8", "foreground": "#000", "secondaryBackground": "#efefef", "buttonBorder": "#ddd" }
    readonly property string buttonTextColor: "#007ac2"

    readonly property bool useInternalGPS: connectionType === sources.eConnectionType.internal
    readonly property bool useExternalGPS: connectionType === sources.eConnectionType.external
    readonly property bool useTCPConnection: connectionType === sources.eConnectionType.network

    readonly property bool isLandscape: isLandscapeOrientation() //(Screen.primaryOrientation === 2) ? true : false
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isIOS: Qt.platform.os === "ios"

    readonly property double maximumSpeedForCompass: 0.5 // meters per second

    property bool initialized

    signal reconnect()

    // -------------------------------------------------------------------------

    Component.onCompleted: {
        fileFolder.makePath(localStoragePath);
        AppFramework.offlineStoragePath = fileFolder.path + "/ArcGIS/My Treks";

        connectionType = app.settings.value("connectionType", sources.eConnectionType.internal)

        if (validateCoordinates(lastLongitude, lastLatitude)) {
            console.log("Navigating to last destination at lat: %1, lon:%2".arg(lastLatitude).arg(lastLongitude));
            requestedDestination = QtPositioning.coordinate(lastLatitude, lastLongitude);
        }

        initialized = true;
    }

    // Components --------------------------------------------------------------

    AppMetrics {
        id: appMetrics
        releaseType: "beta"
    }

    // -------------------------------------------------------------------------

    MainView {
        anchors.fill: parent
    }

    // -------------------------------------------------------------------------

    IconFont {
        id: icons
    }

    // External position sources -----------------------------------------------

    PositioningSources {
        id: sources

        storedDevice: app.storedDevice
        discoverBluetooth: app.discoverBluetooth
        discoverSerialPort: app.discoverSerialPort
    }

    // -------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onErrorChanged: {
            console.log("TCP connection error:", tcpSocket.error, tcpSocket.errorString)

            errorDialog.text = tcpSocket.errorString;
            errorDialog.open();
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onErrorChanged: {
            if (currentDevice) {
                console.log("Device connection error:", currentDevice.error)

                errorDialog.text = currentDevice.error;
                errorDialog.open();
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: discoveryAgent

        property string lastError

        onErrorChanged: {
            if (discoveryAgent.error !== lastError) {
                console.log("Device discovery agent error:", discoveryAgent.error)

                errorDialog.text = discoveryAgent.error;
                errorDialog.open();

                lastError = discoveryAgent.error;
            }
        }
    }

    // -------------------------------------------------------------------------

    Dialog {
        id: errorDialog

        property alias text: label.text

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true

        standardButtons: Dialog.Ok
        title: qsTr("Unable to connect");
        text: ""

        Label {
            id: label

            width: errorDialog.width
            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
            wrapMode: Text.WordWrap
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: discoveryAgentRepeatTimer

        interval: 2000
        running: false
        repeat: false

        onTriggered: {
            if (!discoveryAgent.running) {
                discoveryAgent.start();
            }
        }
    }

    // -------------------------------------------------------------------------

    onReconnect: {
        if (useExternalGPS && storedDevice > "") {
            if (!isConnecting && !isConnected) {
                discoveryAgentRepeatTimer.start();
            } else {
                discoveryAgent.stop();
            }
        } else if (useTCPConnection && hostname > "" && port > "") {
            if (!isConnecting && !isConnected) {
                sources.networkHostSelected(app.hostname, app.port);
            }
        }
    }

    // Settings ----------------------------------------------------------------

    Connections {
        target: app.settings

        onValueChanged: {
            storedDevice = app.settings.value("device", "")
            hostname = app.settings.value("hostname", "")
            port = app.settings.value("port", "")
        }
    }

    // -------------------------------------------------------------------------

    onListenToClipboardChanged: {
        if (initialized) {
            app.settings.setValue("listenToClipboard", listenToClipboard);
        }
    }

    // -------------------------------------------------------------------------

    onLogTreksChanged: {
        if (initialized) {
            app.settings.setValue("logTreks", logTreks);
        }
    }

    // -------------------------------------------------------------------------

    onNightModeChanged: {
        if (initialized) {
            app.settings.setValue("nightMode", nightMode);
        }
    }

    // -------------------------------------------------------------------------

    onUsesMetricChanged: {
        if (initialized) {
            app.settings.setValue("usesMetric", usesMetric);
        }
    }

    // -------------------------------------------------------------------------

    onUseCompassChanged: {
        if (initialized) {
            app.settings.setValue("useCompass", useCompass);
        }
    }

    // -------------------------------------------------------------------------

    onUseHUDChanged: {
        if (initialized) {
            app.settings.setValue("useHUD", useHUD);
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverBluetoothChanged: {
        if (initialized) {
            app.settings.setValue("discoverBluetooth", discoverBluetooth);
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverSerialPortChanged: {
        if (initialized) {
            app.settings.setValue("discoverSerialPort", discoverSerialPort);
        }
    }

    // -------------------------------------------------------------------------

    onCoordinateFormatChanged: {
        if (initialized) {
            app.settings.setValue("coordinateFormat", coordinateFormat);
        }
    }

    // -------------------------------------------------------------------------

    onConnectionTypeChanged: {
        if (initialized) {
            app.settings.setValue("connectionType", connectionType);

            // we have to do a direct comparison here since useInternalGPS has not been updated yet
            if (connectionType !== sources.eConnectionType.internal) {
                lastConnectionType = connectionType;
            }
        }
    }

    // -------------------------------------------------------------------------

    onLastConnectionTypeChanged: {
        if (initialized) {
            app.settings.setValue("lastConnectionType", lastConnectionType);
        }
    }

    // -------------------------------------------------------------------------

    onRequestedDestinationChanged: {
        if (initialized) {
            app.settings.setValue("lastLatitude", requestedDestination.latitude);
            app.settings.setValue("lastLongitude", requestedDestination.longitude);
        }
    }

    // External callbacks ------------------------------------------------------

    onOpenUrl: {
        var urlInfo = AppFramework.urlInfo(url);
        openParameters = urlInfo.queryParameters;

        if (openParameters.hasOwnProperty("stop")) {
            var inCoord = openParameters.stop.split(',');
            requestedDestination = QtPositioning.coordinate(inCoord[0].trim(), inCoord[1].trim());
        }

        if (openParameters.hasOwnProperty("callbackprompt")) {
            callingApplication = openParameters.callbackprompt;
        }

        if (openParameters.hasOwnProperty("callback")) {
            applicationCallback = openParameters.callback;
        }
    }

    // -------------------------------------------------------------------------

    ClipboardDialog {
        id: clipboardDialog

        onUseCoordinates: {
            if (clipLat !== "" && clipLon !== "") {
                console.log("lat: %1, lon:%2".arg(clipLat).arg(clipLon))
                requestedDestination = QtPositioning.coordinate(clipLat.toString(), clipLon.toString());
                dismissCoordinates();
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        id: appClipboard

        target: AppFramework.clipboard

        onDataChanged: {
            checkClip();
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: Qt.application

        onStateChanged: {
            // Needed for UWP
            if(safetyWarningAccepted && Qt.application.state === Qt.ApplicationActive) {
                checkClip();
            }
        }
    }

    // Functions ---------------------------------------------------------------

    function checkClip() {
        var lat = "";
        var lon = "";

        if (AppFramework.clipboard.dataAvailable && listenToClipboard) {
            try {
                var inJson = JSON.parse(AppFramework.clipboard.text);
                if (inJson.hasOwnProperty("latitude") && inJson.hasOwnProperty("longitude")) {
                    lat = inJson.latitude.toString().trim();
                    lon = inJson.longitude.toString().trim();
                }
            } catch(e) {
                if (e.toString().indexOf("JSON.parse: Parse error") > -1) {
                    var incoords = AppFramework.clipboard.text.split(',');
                    if (incoords.length === 2) {
                        lat = incoords[0].toString().trim();
                        lon = incoords[1].toString().trim();
                    }
                }
            } finally {
                if (lat !== "" && lon !== "") {
                    if (validateCoordinates(lat, lon)) {
                        clipboardDialog.clipLat = lat;
                        clipboardDialog.clipLon = lon;
                        clipboardDialog.open();

                        AppFramework.clipboard.clear();
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    function localeIsMetric() {
        switch (locale.measurementSystem) {
        case Locale.ImperialUSSystem:
        case Locale.ImperialUKSystem:
            return false;

        default :
            return true;
        }
    }

    // -------------------------------------------------------------------------

    function validateCoordinates(lat,lon) {
        if (lon.search(longitudeValidator.regExp) > -1 && lat.search(latitudeValidator.regExp) > -1) {
            return true;
        } else {
            return false;
        }
    }

    // -------------------------------------------------------------------------

    function isLandscapeOrientation() {
        var isLandscape = false;

        if (isAndroid || isIOS) {
            isLandscape = Screen.orientation === Qt.LandscapeOrientation || Screen.orientation === Qt.InvertedLandscapeOrientation;
        } else {
            isLandscape = app.width > app.height;
        }

        return isLandscape;
    }

    // -------------------------------------------------------------------------

    function sf(val) {
        return val * AppFramework.displayScaleFactor;
    }

    // -------------------------------------------------------------------------
}
