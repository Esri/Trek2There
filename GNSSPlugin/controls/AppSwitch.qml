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

import ArcGIS.AppFramework 1.0

Switch {
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
        implicitWidth: 40 * AppFramework.displayScaleFactor
        implicitHeight: 16 * AppFramework.displayScaleFactor
        x: parent.x
        y: parent.height / 2 - height / 2
        radius: 8 * AppFramework.displayScaleFactor
        border.width: 2 * AppFramework.displayScaleFactor
        border.color: control.checked ? checkedColor : uncheckedColor
        color: "transparent"
        opacity: enabled ? 1.0 : 0.3

        Rectangle {
            implicitWidth: 22 * AppFramework.displayScaleFactor
            implicitHeight: 22 * AppFramework.displayScaleFactor
            x: control.checked ? parent.width - width : 0
            y: parent.height / 2 - height / 2
            radius: 12 * AppFramework.displayScaleFactor
            border.width: 2 * AppFramework.displayScaleFactor
            border.color: control.checked ? checkedColor : uncheckedColor
            color: control.checked ? checkedColor : uncheckedColor
        }
    }

    //--------------------------------------------------------------------------

    contentItem: AppText {
        id: textControl

        opacity: control.enabled ? 1.0 : 0.3
        color: control.down ? textColor : Qt.darker(textColor, 2)

        text: control.text
        font: control.font

        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        rightPadding: control.spacing
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    //--------------------------------------------------------------------------
}
