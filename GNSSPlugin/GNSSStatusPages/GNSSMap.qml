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
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0
import Esri.ArcGISRuntime 100.8

import "../"
import "../controls"
import "../GNSSManager"

SwipeTab {
    id: gnssMap

    title: qsTr("Map")
    icon: "../images/map-32-f.svg"

    property GNSSManager gnssManager

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        toggleActive();
    }

    //--------------------------------------------------------------------------

    Connections {
        target: gnssManager

        function onActiveChanged() {
            toggleActive();
        }
    }

    //--------------------------------------------------------------------------

    MapView {
        id: mapView

        anchors.fill: parent

        locationDisplay {
            dataSource: DefaultLocationDataSource {
                positionInfoSource: gnssManager
            }

            autoPanMode: Enums.LocationDisplayAutoPanModeRecenter
        }

        Map {
            BasemapTopographic {}
        }
    }

    //--------------------------------------------------------------------------

    function toggleActive() {
        if (gnssManager) {
            if (gnssManager.active) {
                mapView.locationDisplay.start();
                gnssManager.positionChanged(gnssManager.position)
            } else {
                mapView.locationDisplay.stop();
            }
        }
    }

    //--------------------------------------------------------------------------
}

