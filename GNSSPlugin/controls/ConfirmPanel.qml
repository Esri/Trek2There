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
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

Rectangle {
    id: panel

    property var button1Callback
    property var button2Callback
    property var button3Callback
    property string button1Text: defaultButton1Text
    property string button2Text: defaultButton2Text
    property string button3Text: defaultButton3Text
    property alias title: titleText.text
    property color titleTextColor: "#4c4c4c"
    property alias text: messageText.text
    property color textColor: titleTextColor
    property alias detailedText: detailedText.text
    property color detailedTextColor: textColor
    property int detailedTextMaxHeight: 150
    property alias informativeText: informativeText.text
    property color informativeTextColor: textColor
    property alias question: questionText.text
    property color questionColor: "black"
    property alias icon: iconImage.source

    property color accentColor: "#88c448"
    property color backgroundColor: "#f2f3ed"// "#f7f8f8"
    property color iconColor: "transparent" //"#a9d04d"
    property real iconSize: 60
    property string fontFamily: Qt.application.font.family

    property bool verticalLayout: false

    property string defaultButton1Text: qsTr("Yes")
    property string defaultButton2Text: qsTr("No")
    property string defaultButton3Text: "";

    property bool closeOnBackgroundClick: false

    readonly property int buttonWrapMode: verticalLayout ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
    readonly property int buttonMaximumLineCount: verticalLayout ? 3 : 1

    //--------------------------------------------------------------------------

    signal buttonClicked(int index);

    //--------------------------------------------------------------------------

    anchors.fill: parent

    z: 99999
    color: "#60000000"
    opacity: 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: 150
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            if (closeOnBackgroundClick) {
                close();
            }
        }

        onDoubleClicked: {
            if (closeOnBackgroundClick) {
                close();
            }
        }

        onWheel: {}
        onPressAndHold: {}
        onPressed: {}
    }

    RectangularGlow {
        anchors.fill: background
        glowRadius: 5
        spread: 0.2
        color: background.color
        cornerRadius: background.radius + glowRadius
    }

    Rectangle {
        id: background

        anchors {
            left: parent.left
            right: parent.right
            margins: 10 * AppFramework.displayScaleFactor
            verticalCenter: parent.verticalCenter
        }

        height: contentColumn.height + 20 * AppFramework.displayScaleFactor
        radius: 4
        border {
            width: 1
            color: "#60000000"
        }
        color: backgroundColor

        MouseArea {
            anchors.fill: parent

            onClicked: {}
            onDoubleClicked: {}
        }

        Column {
            id: contentColumn

            anchors {
                left: parent.left
                right: parent.right
                margins: 10 * AppFramework.displayScaleFactor
                verticalCenter: parent.verticalCenter
            }

            spacing: 10 * AppFramework.displayScaleFactor

            RowLayout {
                width: parent.width
                spacing: 10 * AppFramework.displayScaleFactor

                Item {
                    Layout.preferredWidth: iconSize * AppFramework.displayScaleFactor
                    Layout.preferredHeight: iconSize * AppFramework.displayScaleFactor
                    Layout.alignment: Qt.AlignHCenter

                    Image {
                        id: iconImage

                        anchors.fill: parent

                        fillMode: Image.PreserveAspectFit
                        visible: source > ""
                    }

                    ColorOverlay {
                        anchors.fill: iconImage

                        color: iconColor
                        source: iconImage
                    }
                }
            }


            RowLayout {
                width: parent.width
                spacing: 10 * AppFramework.displayScaleFactor

                Text {
                    id: titleText

                    Layout.fillWidth: true

                    font {
                        pointSize: 20
                        bold: true
                        family: fontFamily
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: titleTextColor
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Text {
                id: messageText

                width: parent.width
                font {
                    pointSize: 14
                    family: fontFamily
                }
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: text > ""
                color: textColor
                horizontalAlignment: Text.AlignHCenter
            }

            ScrollView {
                width: parent.width
                height: Math.min(detailedText.paintedHeight, detailedTextMaxHeight * AppFramework.displayScaleFactor)
                visible: detailedText.text > ""

                Text {
                    id: detailedText

                    width: contentColumn.width - 20 * AppFramework.displayScaleFactor
                    font {
                        pointSize: 14
                        family: fontFamily
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    //visible: text > ""
                    color: detailedTextColor
                    horizontalAlignment: Text.AlignLeft
                }
            }

            Text {
                id: informativeText

                width: parent.width
                font {
                    pointSize: 12
                    family: fontFamily
                }
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: text > ""
                color: informativeTextColor
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: questionText

                width: parent.width
                font {
                    pointSize: 14
                    family: fontFamily
                }
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: text > ""
                color: questionColor
                horizontalAlignment: Text.AlignHCenter
            }

            GridLayout {
                width: parent.width

                rows: verticalLayout ? -1 : 0
                columns: verticalLayout ? 1: -1

                rowSpacing: 20 * AppFramework.displayScaleFactor
                columnSpacing: 5 * AppFramework.displayScaleFactor

                ConfirmButton {
                    id: button1

                    Layout.fillWidth: verticalLayout
                    Layout.alignment: verticalLayout ? Qt.AlignHCenter : button2.visible ? Qt.AlignLeft : Qt.AlignHCenter

                    accentColor: accentColor
                    text: button1Text
                    visible: text > ""
                    fontFamily: panel.fontFamily
                    wrapMode: buttonWrapMode
                    maximumLineCount: buttonMaximumLineCount

                    onClicked: {
                        close();

                        if (button1Callback) {
                            button1Callback();
                        }

                        buttonClicked(1);
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    visible: !verticalLayout && button2.visible && !button3.visible
                }

                ConfirmButton {
                    id: button2

                    Layout.fillWidth: verticalLayout
                    Layout.alignment: verticalLayout ? Qt.AlignHCenter : 0

                    accentColor: accentColor
                    text: button2Text
                    visible: text > ""
                    fontFamily: panel.fontFamily
                    wrapMode: buttonWrapMode
                    maximumLineCount: buttonMaximumLineCount

                    onClicked: {
                        if (button2Callback) {
                            button2Callback();
                        }

                        buttonClicked(2);
                        close();
                    }
                }

                ConfirmButton {
                    id: button3

                    Layout.fillWidth: verticalLayout
                    Layout.alignment: verticalLayout ? Qt.AlignHCenter : 0

                    accentColor: accentColor
                    text: button3Text
                    visible: text > ""
                    fontFamily: panel.fontFamily
                    wrapMode: buttonWrapMode
                    maximumLineCount: buttonMaximumLineCount

                    onClicked: {
                        if (button3Callback) {
                            button3Callback();
                        }

                        buttonClicked(3);
                        close();
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    function clear() {
        title = "";
        text = "";
        informativeText.text = "";
        detailedText.text = "";
        question = "";
        icon = "";
        iconColor = "transparent";
        button1Text = defaultButton1Text;
        button2Text = defaultButton2Text;
        button3Text = defaultButton3Text;
        verticalLayout = false;
        closeOnBackgroundClick = false;
    }

    //--------------------------------------------------------------------------

    function open() {
        opacity = 1;
    }

    function close() {
        opacity = 0;
    }

    //--------------------------------------------------------------------------

    function show(callback1, callback2, callback3) {
        Qt.inputMethod.hide();

        button1Callback = callback1;
        button2Callback = callback2;
        button3Callback = callback3;

        open();
    }

    //--------------------------------------------------------------------------
}
