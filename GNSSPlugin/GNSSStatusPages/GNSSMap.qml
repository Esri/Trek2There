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

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtPositioning 5.12
import QtLocation 5.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "../"
import "../controls"
import "../GNSSManager"

SwipeTab {
    id: gnssMap

    title: qsTr("Map")
    icon: "../images/map-black-24dp.svg"

    //--------------------------------------------------------------------------

    property GNSSManager gnssManager
    property var position: gnssManager.position

    //--------------------------------------------------------------------------

    Connections {
        target: gnssManager

        onNewPosition: {
            gnssMap.position = position;
        }
    }

    //--------------------------------------------------------------------------

    Map {
        id: mapView

        anchors.fill: parent

        plugin: Plugin {
            preferred: ["AppStudio"]
        }

        center: positionCircle.center
        zoomLevel: 16

        MapCircle {
            id: positionCircle

            center: position && position.coordinate ? position.coordinate : QtPositioning.coordinate()
            radius: position && position.horizontalAccuracy ? position.horizontalAccuracy : 20

            border.color: "#8000B2FF"
            border.width: 2
            color: position && position.horizontalAccuracy ? "#4000B2FF" : "transparent"
        }

        MapQuickItem {
            id: locationPin

            anchorPoint.x: pinImage.width/2
            anchorPoint.y: pinImage.height

            visible: app.requestedDestination && app.requestedDestination.isValid
            coordinate: app.requestedDestination && app.requestedDestination.isValid ? app.requestedDestination : QtPositioning.coordinate()

            sourceItem: Image {
                id: pinImage

                width: 40 * AppFramework.displayScaleFactor
                height: width

                source: "../../images/map_pin.png"
            }
        }
    }

    //--------------------------------------------------------------------------
}

