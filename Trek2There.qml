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

import QtQuick 2.5
import QtPositioning 5.4
import QtQuick.Window 2.2

import ArcGIS.AppFramework 1.0

import "AppMetrics"
import "IconFont"

//------------------------------------------------------------------------------

App {

    id: app
    width: 480
    height: 640

    Accessible.role: Accessible.Window

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool safteyWarningAccepted: app.settings.boolValue("safteyWarningAccepted", false)
    property bool showSafetyWarning: app.settings.boolValue("showSafetyWarning", true)
    property bool nightMode: app.settings.boolValue("nightMode", false)
    property bool listenToClipboard: app.settings.boolValue("listenToClipboard", true)

    property RegExpValidator latitudeValidator: RegExpValidator { regExp: /^[-]?90$|^[-]?[1-8][0-9](\.\d{1,})?$|^[-]?[1-9](\.\d{1,})?$/g }
    property RegExpValidator longitudeValidator: RegExpValidator { regExp: /^[-]?180$|^[-]?1[0-7][0-9](\.\d{1,})?$|^[-]?[1-9][0-9](\.\d{1,})?$|^[-]?[1-9](\.\d{1,})?$/g }

    property var locale: Qt.locale()
    property bool usesMetric: app.settings.boolValue("usesMetric", localeIsMetric())

    property TrekLogger trekLogger: TrekLogger{}
    property bool logTreks: app.settings.boolValue("logTreks", false)
    property FileFolder fileFolder: FileFolder{ path: AppFramework.userHomePath }
    property string localStoragePath: fileFolder.path + "/ArcGIS/My Treks"

    property bool isLandscape: (Screen.primaryOrientation === 2) ? true : false
    property bool useDirectionOfTravelCircle: true

    property var requestedDestination: null
    property var openParameters: null
    property string callingApplication: ""
    property string applicationCallback: ""

    property int baseFontSize: 14
    property double largeFontSize: baseFontSize * 1.3
    property double extraLargeFontSize: baseFontSize * 3
    property double smallFontSize: baseFontSize * .8
    property double xSmallFontSize: baseFontSize * .6

    readonly property var nightModeSettings: { "background": "#000", "foreground": "#f8f8f8", "secondaryBackground": "#2c2c2c", "buttonBorder": "#2c2c2c" }
    readonly property var dayModeSettings: { "background": "#f8f8f8", "foreground": "#000", "secondaryBackground": "#efefef", "buttonBorder": "#ddd" }
    readonly property string buttonTextColor: "#007ac2"

    Component.onCompleted: {
        fileFolder.makePath(localStoragePath);
        AppFramework.offlineStoragePath = fileFolder.path + "/ArcGIS/My Treks"
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    AppMetrics{
        id: appMetrics
        releaseType: "beta"
    }

    MainView{
        anchors.fill: parent
    }

    IconFont{
        id: icons
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onOpenUrl: {
        var urlInfo = AppFramework.urlInfo(url);
        openParameters = urlInfo.queryParameters;

        if(openParameters.hasOwnProperty("stop")){
            var inCoord = openParameters.stop.split(',');
            requestedDestination =  QtPositioning.coordinate(inCoord[0].trim(), inCoord[1].trim());
        }

        if(openParameters.hasOwnProperty("callbackprompt")){
            callingApplication = openParameters.callbackprompt;

        }

        if(openParameters.hasOwnProperty("callback")){
            applicationCallback = openParameters.callback;
        }
    }

    //--------------------------------------------------------------------------

    onNightModeChanged: {
        app.settings.setValue("nightMode", nightMode);
    }

    //--------------------------------------------------------------------------

    onUsesMetricChanged: {
        app.settings.setValue("usesMetric", usesMetric);
    }

    //--------------------------------------------------------------------------

    onLogTreksChanged: {
        app.settings.setValue("logTreks", logTreks);
    }

    // FUNCTIONS ///////////////////////////////////////////////////////////////

    function localeIsMetric(){
        switch (locale.measurementSystem) {
            case Locale.ImperialUSSystem:
            case Locale.ImperialUKSystem:
                return false;

            default :
                return true;
        }
    }

    //--------------------------------------------------------------------------

    function validCoordinates(lat,lon){
        if(lon.search(longitudeValidator.regExp) > -1 && lat.search(latitudeValidator.regExp) > -1){
            return true;
        }
        else{
            return false;
        }
    }

    // CONNECTIONS /////////////////////////////////////////////////////////////

    Connections{
        target: AppFramework.clipboard

        onDataChanged: {

            var inLat, inLon

            if(AppFramework.clipboard.dataAvailable && listenToClipboard){
                try{
                    var inJson = JSON.parse(AppFramework.clipboard.text);
                    if(inJson.hasOwnProperty("latitude") && inJson.hasOwnProperty("longitude")){
                        inLat = inJson.latitude.toString().trim();
                        inLon = inJson.longitude.toString().trim();
                        if(validCoordinates(inLat, inLon)){
                            requestedDestination =  QtPositioning.coordinate(inLat, inLon);
                        }
                    }
                }
                catch(e){
                    if(e.toString().indexOf("JSON.parse: Parse error") > -1){
                        var incoords = AppFramework.clipboard.text.split(',');
                        if(incoords.length === 2){
                            inLat = incoords[0].toString().trim();
                            inLon = incoords[1].toString().trim();
                            if(validCoordinates(inLat, inLon)){
                                requestedDestination =  QtPositioning.coordinate(inLat, inLon);
                            }
                        }
                    }
                }
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////

}
