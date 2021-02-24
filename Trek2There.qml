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
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtPositioning 5.15

// -----------------------------------------------------------------------------

import ArcGIS.AppFramework 1.0

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
    property int baseFontSize: 14 * AppFramework.displayScaleFactor
    property double largeFontSize: baseFontSize * 1.3
    property double extraLargeFontSize: baseFontSize * 3
    property double smallFontSize: baseFontSize * .8
    property double xSmallFontSize: baseFontSize * .6

    readonly property var dayModeSettings: { "background": "#f8f8f8", "foreground": "#000000", "secondaryBackground": "#efefef", "buttonBorder": "#ddd" }
    readonly property var nightModeSettings: { "background": "#000000", "foreground": "#f8f8f8", "secondaryBackground": "#2c2c2c", "buttonBorder": "#2c2c2c" }
    readonly property color buttonTextColor: "#007ac2"

    readonly property bool isLandscape: isLandscapeOrientation() //(Screen.primaryOrientation === 2) ? true : false
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isIOS: Qt.platform.os === "ios"

    readonly property double maximumSpeedForCompass: 0.5 // meters per second

    property bool initialized

    // -------------------------------------------------------------------------

    Component.onCompleted: {
        fileFolder.makePath(localStoragePath);
        AppFramework.offlineStoragePath = fileFolder.path + "/ArcGIS/My Treks";

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

        app: app
    }

    // -------------------------------------------------------------------------

    IconFont {
        id: icons
    }

    // Settings ----------------------------------------------------------------

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

    onCoordinateFormatChanged: {
        if (initialized) {
            app.settings.setValue("coordinateFormat", coordinateFormat);
        }
    }

    // -------------------------------------------------------------------------

    onRequestedDestinationChanged: {
        if (initialized && requestedDestination) {
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
