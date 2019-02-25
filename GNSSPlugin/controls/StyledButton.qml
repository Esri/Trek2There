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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

Button {
    id: button

    property real textPointSize: 13
    property int wrapMode: Text.NoWrap
    property int maximumLineCount: 1
    property int lineCount: 1

    property color backgroundColor: "#fefefe"
    property color textColor: "black"
    property color borderColor: "#a6a8ab"

    property color disabledBackgroundColor: backgroundColor
    property color disabledTextColor: "lightgrey"
    property color disabledBorderColor: "darkgrey"

    property color hoveredBackgroundColor: "#e1f0fb"
    property color hoveredTextColor: textColor

    property color pressedBackgroundColor: "#90cdf2"
    property color pressedTextColor: hoveredTextColor

    property int activateDelay: 0
    property color activateColor: "#ff4a4d"

    property int radius: height / (lineCount + 1)
    property int labelSpacing: 2 * AppFramework.displayScaleFactor

    readonly property alias progress: button.__progress
    property real __progress: 0.0

    property string fontFamily: Qt.application.font.family

    signal activated()

    activeFocusOnPress: true

    //--------------------------------------------------------------------------

    Behavior on __progress {
        id: progressBehavior

        NumberAnimation {
            id: numberAnimation
        }
    }

    //--------------------------------------------------------------------------

    onProgressChanged: {
        if (__progress === 1.0) {
            if (activeFocusOnPress) {
                forceActiveFocus();
            }
            checked = true;
            activated();
        }
    }

    //--------------------------------------------------------------------------

    onCheckedChanged: {
        if (checked) {
            if (__progress < 1) {
                // Programmatically activated the button; don't animate.
                progressBehavior.enabled = false;
                __progress = 1;
                progressBehavior.enabled = true;
            }
        } else {
            // Unchecked the button after it was flashing; it should instantly stop
            // flashing (with no reversed progress bar).
            progressBehavior.enabled = false;
            __progress = 0;
            progressBehavior.enabled = true;
        }
    }

    //--------------------------------------------------------------------------

    onPressedChanged: {
        if (checked) {
            if (pressed) {
                // Pressed the button to stop the activation.
                checked = false;
            }
        } else {
            var effectiveDelay = pressed ? activateDelay : activateDelay * 0.3;
            // Not active. Either the button is being held down or let go.
            numberAnimation.duration = Math.max(0, (pressed ? 1 - __progress : __progress) * effectiveDelay);
            __progress = pressed ? 1 : 0;
        }
    }

    //--------------------------------------------------------------------------

    style: ButtonStyle {
        padding {
            left: 10 * AppFramework.displayScaleFactor
            right: 10 * AppFramework.displayScaleFactor
            top: 6 * AppFramework.displayScaleFactor
            bottom: 6 * AppFramework.displayScaleFactor
        }

        label: RowLayout {
            spacing: labelSpacing

            Item {
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: Layout.preferredHeight

                visible: labelImage.source > ""

                Image {
                    id: labelImage

                    anchors.fill: parent

                    source: button.iconSource
                    fillMode: Image.PreserveAspectFit
                }

                ColorOverlay {
                    anchors.fill: labelImage

                    source: labelImage
                    color: labelText.color
                }
            }

            AppText {
                id: labelText

                Layout.fillWidth: true
                Layout.fillHeight: true

                text: button.text
                color: button.enabled
                       ? button.pressed
                         ? pressedTextColor
                         : button.hovered
                           ? hoveredTextColor
                           : textColor
                : disabledTextColor

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                minimumPointSize: 8
                pointSize: textPointSize
                fontFamily: button.fontFamily
                fontSizeMode: Text.Fit
                elide: Text.ElideRight
                wrapMode: button.wrapMode
                maximumLineCount: button.maximumLineCount

                onLineCountChanged: {
                    button.lineCount = lineCount;
                }
            }
        }

        background: Rectangle {
            implicitWidth: 110

            radius: button.radius

            color: button.enabled
                   ? button.pressed
                     ? pressedBackgroundColor
                     : button.hovered
                       ? hoveredBackgroundColor
                       : backgroundColor
            : disabledBackgroundColor

            border {
                color: button.enabled ? borderColor : disabledBorderColor
                width: button.isDefault ? 2 : 1
            }

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                radius: parent.radius
                width: parent.width * button.progress

                color: activateColor
                visible: activateDelay > 0 && progress > 0 && width > radius * 2
            }
        }
    }

    //--------------------------------------------------------------------------
}
