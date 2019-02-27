/* Copyright 2018 Esri
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

import ArcGIS.AppFramework.Devices 1.0

Item {
    property PositionSourceManager positionSourceManager
    property NmeaSource nmeaSource: positionSourceManager.nmeaSource
    property DeviceDiscoveryAgent discoveryAgent: positionSourceManager.discoveryAgent
    property PositioningSourcesController controller: positionSourceManager.controller

    readonly property bool active: positionSourceManager.active

    //--------------------------------------------------------------------------

    property int maximumDataAge: 5000
    property int maximumPositionAge: 5000

    //--------------------------------------------------------------------------

    property int kAlertConnected: 1
    property int kAlertDisconnected: 2
    property int kAlertNoData: 3
    property int kAlertNoPosition: 4

    //--------------------------------------------------------------------------

    property date startTime
    property date dataReceivedTime
    property date positionTime

    //--------------------------------------------------------------------------

    property bool debug: false

    //--------------------------------------------------------------------------

    signal alert(int alertType)

    //--------------------------------------------------------------------------

    onActiveChanged: {
        console.log("Position source monitoring active:", active);

        if (active) {
            initialize();
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: timer

        interval: 10000
        triggeredOnStart: false
        repeat: true
        running: active

        onTriggered: {
            monitorCheck();
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        id: nmeaSourceConnections

        target: nmeaSource
        enabled: active && positionSourceManager.isGNSS

        onReceivedNmeaData: {
            dataReceivedTime = new Date();
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        id: positionSourceManagerConnections

        target: positionSourceManager
        enabled: active

        onNewPosition: {
            positionTime = new Date();
        }

        onIsConnectedChanged: {
            if (positionSourceManager.isGNSS) {
                if (positionSourceManager.isConnected) {
                    alert(kAlertConnected);
                } else {
                    alert(kAlertDisconnected);
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    function initialize() {
        startTime = new Date();
        dataReceivedTime = new Date();
        positionTime = new Date();
    }

    //--------------------------------------------------------------------------

    function monitorCheck() {
        var now = new Date().valueOf();

        if (debug) {
            console.log("monitorCheck");
            console.log(" startTime:", startTime);
        }

        if (nmeaSourceConnections.enabled && !positionSourceManager.onSettingsPage && !positionSourceManager.isConnecting && !discoveryAgent.running) {
            var dataAge = now - dataReceivedTime.valueOf();

            if (debug) {
                console.log(" dataReceivedTime:", dataReceivedTime);
                console.log(" dataAge:", dataAge);
            }

            if (dataAge > maximumDataAge) {
                alert(kAlertNoData);
                return;
            }
        }


        if (positionSourceManagerConnections.enabled && !positionSourceManager.onSettingsPage && !positionSourceManager.isConnecting && !discoveryAgent.running) {
            var positionAge = now - positionTime.valueOf();

            if (debug) {
                console.log(" positionTime:", startTime);
                console.log(" positionAge:", positionAge);
            }

            if (positionAge > maximumPositionAge) {
                alert(kAlertNoPosition);
                return;
            }
        }
    }

    //--------------------------------------------------------------------------
}
