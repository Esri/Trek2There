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

//------------------------------------------------------------------------------

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Positioning 1.0

//------------------------------------------------------------------------------

import "AppMetrics"
import "IconFont"
import "views"
import "controls"

//------------------------------------------------------------------------------

App {
    id: app

    width: 480 * windowScaleFactor
    height: 640 * windowScaleFactor

    Accessible.role: Accessible.Window

    // PROPERTIES //////////////////////////////////////////////////////////////

    property alias positionSource: sources.positionSource
    property alias satelliteInfoSource: sources.satelliteInfoSource
    property alias nmeaSource: sources.nmeaSource
    property alias tcpSocket: sources.tcpSocket
    property alias discoveryAgent: sources.discoveryAgent

    property string storedDevice: settings.value("device", "");

    property Device currentDevice: sources.currentDevice
    property bool isConnecting: sources.isConnecting
    property bool isConnected: sources.isConnected
    property alias connectionType: sources.connectionType

    property bool useInternalGPS: connectionType === sources.eConnectionType.internal
    property bool useExternalGPS: connectionType === sources.eConnectionType.external
    property bool useTCPConnection: connectionType === sources.eConnectionType.network

    property bool safteyWarningAccepted: app.settings.boolValue("safteyWarningAccepted", false)
    property bool showSafetyWarning: app.settings.boolValue("showSafetyWarning", true)
    property bool nightMode: app.settings.boolValue("nightMode", false)
    property bool listenToClipboard: app.settings.boolValue("listenToClipboard", true)
    property bool useExperimentalFeatures: app.settings.boolValue("useExperimentalFeatures", false)
    property int currentDistanceFormat: app.settings.numberValue("currentDistanceFormat", 0)

    property RegExpValidator latitudeValidator: RegExpValidator { regExp: /^[-]?90$|^[-]?[1-8][0-9](\.\d{1,})?$|^[-]?[1-9](\.\d{1,})?$/g }
    property RegExpValidator longitudeValidator: RegExpValidator { regExp: /^[-]?180$|^[-]?1[0-7][0-9](\.\d{1,})?$|^[-]?[1-9][0-9](\.\d{1,})?$|^[-]?[1-9](\.\d{1,})?$/g }

    property var locale: Qt.locale()
    property bool usesMetric: app.settings.boolValue("usesMetric", localeIsMetric())

    property TrekLogger trekLogger: TrekLogger{}
    property bool logTreks: app.settings.boolValue("logTreks", false)
    property FileFolder fileFolder: FileFolder{ path: AppFramework.userHomePath }
    property string localStoragePath: fileFolder.path + "/ArcGIS/My Treks"

    property bool isLandscape: isLandscapeOrientation() //(Screen.primaryOrientation === 2) ? true : false
    property bool useDirectionOfTravelCircle: true

    property var requestedDestination: null
    property var openParameters: null
    property string callingApplication: ""
    property string applicationCallback: ""

    property int sideMargin: sf(14)
    property int baseFontSize: 14
    property double largeFontSize: baseFontSize * 1.3
    property double extraLargeFontSize: baseFontSize * 3
    property double smallFontSize: baseFontSize * .8
    property double xSmallFontSize: baseFontSize * .6

    readonly property var nightModeSettings: { "background": "#000", "foreground": "#f8f8f8", "secondaryBackground": "#2c2c2c", "buttonBorder": "#2c2c2c" }
    readonly property var dayModeSettings: { "background": "#f8f8f8", "foreground": "#000", "secondaryBackground": "#efefef", "buttonBorder": "#ddd" }
    readonly property string buttonTextColor: "#007ac2"

    readonly property real windowScaleFactor: !(Qt.platform.os === "windows" || Qt.platform.os === "unix" || Qt.platform.os === "linux") ? 1 : AppFramework.displayScaleFactor
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isIOS: Qt.platform.os === "ios"

    property bool initialized

    Component.onCompleted: {
        fileFolder.makePath(localStoragePath);
        AppFramework.offlineStoragePath = fileFolder.path + "/ArcGIS/My Treks";

        connectionType = app.settings.value("connectionType", sources.eConnectionType.internal)
        initialized = true;
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    AppMetrics {
        id: appMetrics
        releaseType: "beta"
    }

    //------------------------------------------------------------------------------

    MainView {
        anchors.fill: parent
    }

    //------------------------------------------------------------------------------

    IconFont {
        id: icons
    }

    //------------------------------------------------------------------------------

    ClipboardDialog {
        id: clipboardDialog

        clipLat: appClipboard.inLat
        clipLon: appClipboard.inLon

        onUseCoordinates: {
            if (clipLat !== "" && clipLon !== "") {
                console.log("lat: %1, lon:%2".arg(clipLat).arg(clipLon))
                requestedDestination = QtPositioning.coordinate(clipLat.toString(), clipLon.toString());
                dismissCoordinates();
            }
        }

        onDismissCoordinates: {
            appClipboard.inLat = "";
            appClipboard.inLon = "";
        }
    }

    //--------------------------------------------------------------------------

    PositioningSources {
        id: sources

        storedDevice: app.storedDevice
    }

    //--------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onErrorChanged: {
            console.log("Connection error:", tcpSocket.error, tcpSocket.errorString)

            errorDialog.text = tcpSocket.errorString;
            errorDialog.open();
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onErrorChanged: {
            if (currentDevice) {
                console.log("Connection error:", currentDevice.error)

                errorDialog.text = currentDevice.error;
                errorDialog.open();
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

            Layout.fillWidth: true
            font.pixelSize: baseFontSize
            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onOpenUrl: {
        var urlInfo = AppFramework.urlInfo(url);
        openParameters = urlInfo.queryParameters;

        if (openParameters.hasOwnProperty("stop")) {
            var inCoord = openParameters.stop.split(',');
            requestedDestination =  QtPositioning.coordinate(inCoord[0].trim(), inCoord[1].trim());
        }

        if (openParameters.hasOwnProperty("callbackprompt")) {
            callingApplication = openParameters.callbackprompt;

        }

        if (openParameters.hasOwnProperty("callback")) {
            applicationCallback = openParameters.callback;
        }
    }

    //--------------------------------------------------------------------------

    onNightModeChanged: {
        if (initialized) {
            app.settings.setValue("nightMode", nightMode);
        }
    }

    //--------------------------------------------------------------------------

    onUsesMetricChanged: {
        if (initialized) {
            app.settings.setValue("usesMetric", usesMetric);
        }
    }

    //--------------------------------------------------------------------------

    onConnectionTypeChanged: {
        if (initialized) {
            app.settings.setValue("connectionType", connectionType);
        }
    }

    //--------------------------------------------------------------------------

    onLogTreksChanged: {
        if (initialized) {
            app.settings.setValue("logTreks", logTreks);
        }
    }

    //--------------------------------------------------------------------------

    onUseExperimentalFeaturesChanged: {
        if (initialized) {
            app.settings.setValue("useExperimentalFeatures", useExperimentalFeatures);
        }
    }

    //--------------------------------------------------------------------------

    onCurrentDistanceFormatChanged: {
        if (initialized) {
            app.settings.setValue("currentDistanceFormat", currentDistanceFormat);
        }
    }

    // FUNCTIONS ///////////////////////////////////////////////////////////////

    function localeIsMetric() {
        switch (locale.measurementSystem) {
            case Locale.ImperialUSSystem:
            case Locale.ImperialUKSystem:
                return false;

            default :
                return true;
        }
    }

    //--------------------------------------------------------------------------

    function validCoordinates(lat,lon) {
        if (lon.search(longitudeValidator.regExp) > -1 && lat.search(latitudeValidator.regExp) > -1) {
            return true;
        } else {
            return false;
        }
    }

    //--------------------------------------------------------------------------

    function isLandscapeOrientation() {
        var isLandscape = false;

        if (isAndroid || isIOS) {
            isLandscape = Screen.orientation === Qt.LandscapeOrientation || Screen.orientation === Qt.InvertedLandscapeOrientation;
        } else {
            isLandscape = app.width > app.height;
        }

        return isLandscape;
    }

    //--------------------------------------------------------------------------

    function sf(val) {
        return val * AppFramework.displayScaleFactor;
    }

    // CONNECTIONS /////////////////////////////////////////////////////////////

    Connections {
        id: appClipboard
        target: AppFramework.clipboard

        property string inLat: ""
        property string inLon: ""

        onDataChanged: {

            console.log('there is data on the clipboard');

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
                        if (validCoordinates(lat, lon)) {
                            appClipboard.inLat = lat;
                            appClipboard.inLon = lon;
                            clipboardDialog.clipLat = lat;
                            clipboardDialog.clipLon = lon;
                            clipboardDialog.open();
                        }
                    }
                }
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////

}
