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
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0

GroupRectangle {
    id: rect

    property alias layout: layout
    default property alias layoutContent: layout.data
    property alias title: groupText.text
    property alias spacing: layout.spacing
    property string fontFamily: Qt.application.font.family
    property real pointSize: 16
    property bool bold: true


    //--------------------------------------------------------------------------

    signal titleClicked()
    signal titlePressAndHold()

    //--------------------------------------------------------------------------

    color: "#07000000"
    implicitHeight: layout.height + layout.anchors.margins * 3


    content: ColumnLayout {
        id: layout

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10 * AppFramework.displayScaleFactor
        }

        spacing: 5 * AppFramework.displayScaleFactor

        AppText {
            id: groupText

            Layout.fillWidth: true
            Layout.bottomMargin: layout.spacing

            fontFamily: rect.fontFamily
            pointSize: rect.pointSize
            bold: rect.bold

            visible: text > ""

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    titleClicked();
                }

                onPressAndHold: {
                    titlePressAndHold();
                }
            }
        }
    }

    //--------------------------------------------------------------------------
}
