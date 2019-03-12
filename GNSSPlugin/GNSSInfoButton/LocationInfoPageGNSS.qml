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

import ArcGIS.AppFramework 1.0

import "../GNSSManager"
import "../controls"

Page {
    id: gnssInfo

    property PositionSourceManager positionSourceManager
    property var position: ({})

    contentMargins: 0

    //--------------------------------------------------------------------------

    title: qsTr("GNSS Location Status")

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager

        onNewPosition: {
            gnssInfo.position = position;
        }
    }

    //--------------------------------------------------------------------------

    contentItem: SwipeTabView {
        fontFamily: gnssInfo.fontFamily
        tabBarBackgroundColor: headerBarColor//backgroundColor
        selectedTextColor: textColor

        color: backgroundColor

        GNSSData {
            positionSourceManager: gnssInfo.positionSourceManager
            position: gnssInfo.position
        }

        GNSSSkyPlot {
            positionSourceManager: gnssInfo.positionSourceManager
            fontFamily: gnssInfo.fontFamily
        }

        GNSSDebug {
            positionSourceManager: gnssInfo.positionSourceManager
            fontFamily: gnssInfo.fontFamily
        }
    }

    //--------------------------------------------------------------------------
}
