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
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

CheckBox {
    id: control

    property color checkedColor: locationSettingsTab.secondaryForegroundColor
    property color uncheckedColor: locationSettingsTab.foregroundColor
    property color textColor: locationSettingsTab.foregroundColor

    property string fontFamily: Qt.application.font.family
    property real pointSize: 12
    property bool bold: false

    //--------------------------------------------------------------------------

    implicitHeight: Math.max(25 * AppFramework.displayScaleFactor, textControl.paintedHeight + 6 * AppFramework.displayScaleFactor)
    spacing: 10 * AppFramework.displayScaleFactor

    font {
        family: control.fontFamily
        pointSize: control.pointSize
        bold: control.bold
    }

    //--------------------------------------------------------------------------

    indicator: Rectangle {
        implicitWidth: 20 * AppFramework.displayScaleFactor
        implicitHeight: 20 * AppFramework.displayScaleFactor

        x: control.leftPadding
        y: parent.height / 2 - height / 2

        border {
            width: 2 * AppFramework.displayScaleFactor
            color: control.checked ? checkedColor : uncheckedColor
        }

        color: "transparent"
        opacity: control.enabled ? 1.0 : 0.3

        Image {
            id: image

            anchors.centerIn: parent
            width: parent.width - 8 * AppFramework.displayScaleFactor
            source: "../images/checkmark.png"
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        ColorOverlay {
            visible: control.checked
            anchors.fill: image
            source: image
            color: checkedColor
        }
    }

    //--------------------------------------------------------------------------

    contentItem: AppText {
        id: textControl

        opacity: control.enabled ? 1.0 : 0.3

        text: control.text
        font: control.font
        color: control.down ? textColor : Qt.darker(textColor, 2)

        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    //--------------------------------------------------------------------------
}

