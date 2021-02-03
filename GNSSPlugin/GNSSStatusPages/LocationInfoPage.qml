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

import ArcGIS.AppFramework 1.0

import "../controls"
import "../GNSSManager"

Page {
    id: locationInfoPage

    default property alias contentData: tabView.contentData

    property bool showData: true
    property bool showMap: true
    property bool showSkyPlot: true
    property bool showDebug: true

    bottomSpacingBackgroundColor: headerBarBackgroundColor

    //--------------------------------------------------------------------------

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager
    property NmeaLogger nmeaLogger

    property color labelColor: "grey"
    property color debugButtonColor: headerBarBackgroundColor
    property color recordingColor: "mediumvioletred"

    //--------------------------------------------------------------------------

    SwipeTabView {
        id: tabView

        anchors.fill: parent

        fontFamily: locationInfoPage.fontFamily
        tabBarBackgroundColor: locationInfoPage.headerBarBackgroundColor
        selectedTextColor: locationInfoPage.headerBarTextColor
        color: locationInfoPage.backgroundColor

        clip: true
    }

    //--------------------------------------------------------------------------
}
