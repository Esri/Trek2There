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
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import QtPositioning 5.12

import ArcGIS.AppFramework 1.0

Item {
    id: dialog

    visible: false

    //-----------------------------------------------------------------------------------

    property string title: ""
    property string description: ""
    property string leftBtnString: ""
    property string rightBtnString: ""
    property var leftFunction
    property var rightFunction

    property color backgroundColor: "#ffffff"
    property color buttonColor: "#007ac2"
    property color titleColor: "#303030"
    property color textColor: "#303030"

    property string fontFamily: Qt.application.font.family
    property string thumbnail: ""

    property var clipLat: Math.NaN
    property var clipLon: Math.NaN

    readonly property real scaleFactor: AppFramework.displayScaleFactor
    readonly property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    signal clickLeft()
    signal clickRight()
    signal useCoordinates()

    //-----------------------------------------------------------------------------------

    function open() {
        openDialog(qsTr("Use Coordinates on Clipboard"),
                            qsTr("It looks like you copied coordinates to the clipboard. Do you want to use them in Trek2There?"),
                            qsTr("NO"),
                            qsTr("YES"),
                            discarded, accepted);
    }

    function accepted() {
        useCoordinates();
        swapError.hide();
    }

    function discarded() {
        dismissCoordinates();
        swapError.hide();
    }

    function openDialog(dialogTitle, dialogDescription, dialogLeftStr, dialogRightStr, left, right) {
        resetDialog();

        title = dialogTitle;
        description = dialogDescription
        leftBtnString = dialogLeftStr;
        rightBtnString = dialogRightStr;
        leftFunction = left;
        rightFunction = right;

        dialog.visible = true
    }

    function resetDialog() {
        title = "";
        description = "";
        leftBtnString = "";
        rightBtnString = "";
    }

    function dismissCoordinates() {
        clipLat = "";
        clipLon = "";
    }

    //-----------------------------------------------------------------------------------
    // backbutton handling

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
        }
    }

    Keys.onReleased: {
        if (visible) {
            if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
                event.accepted = true
                visible = false;
            }
        }
    }

    //-----------------------------------------------------------------------------------
    // mask

    Rectangle {
        anchors.fill: parent
        color: "#66000000"

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onClicked: {
                discarded();
                dialog.visible = false;
            }
        }
    }

    Rectangle {
        id: rect

        width: Math.max(280 * scaleFactor, parent.width * 0.8)
        height: container.height
        anchors.centerIn: parent

        color: backgroundColor

        ColumnLayout {
            id: container

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            Label {
                Layout.preferredWidth: parent.width - 48 * scaleFactor
                Layout.alignment: Qt.AlignHCenter

                text: title
                visible: title > ""

                font.pixelSize: 20 * scaleFactor
                font.family: dialog.fontFamily
                font.letterSpacing: 0.15 * scaleFactor
                font.bold: true
                color: dialog.titleColor
                lineHeight: 27 * scaleFactor
                lineHeightMode: Text.FixedHeight

                padding: 0

                wrapMode: Text.Wrap

                LayoutMirroring.enabled: false

                horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: thumbnail > "" ? 24 * scaleFactor : 8 * scaleFactor
                visible: (title > "" || thumbnail > "") && description > ""
            }

            Label {
                Layout.preferredWidth: parent.width - 48 * scaleFactor
                Layout.alignment: Qt.AlignHCenter

                text: description
                visible: description > ""

                font.pixelSize: 16 * scaleFactor
                font.family: dialog.fontFamily
                color: dialog.textColor
                font.letterSpacing: 0
                lineHeight: 24 * scaleFactor
                lineHeightMode: Text.FixedHeight

                padding: 0

                wrapMode: Text.Wrap

                horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            Rectangle {
                Layout.preferredHeight: 80 * scaleFactor
                Layout.preferredWidth: parent.width - 48 * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                color: "#eee"
                Accessible.role: Accessible.Pane

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: sf(5)
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "#eee"
                        Accessible.role: Accessible.Pane

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            Text {
                                visible: !swapError.visible

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Latitude (y): %1".arg(clipLat)
                                font.pixelSize: 16 * scaleFactor
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("This is the latitude or y value")
                            }

                            Text {
                                visible: !swapError.visible

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Longitude (x): %1".arg(clipLon)
                                font.pixelSize: 16 * scaleFactor
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("This is the longitude or x value")
                            }

                            StatusIndicator {
                                id: swapError

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.margins: sf(5)
                                Layout.leftMargin: 0
                                messageType: swapError.error
                                message: qsTr("Invalid coordinate swap.")
                                hideAutomatically: true
                                hideAfter: 2000
                                Accessible.role: Accessible.AlertMessage
                                Accessible.name: message
                            }
                        }
                    }

                    // ---------------------------------------------------------

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: sf(50)
                        color: "#eee"
                        Accessible.role: Accessible.Pane

                        Button {
                            anchors.fill: parent

                            Text {
                                font.family: icons.name
                                text: icons.swap
                                anchors.centerIn: parent
                                color: buttonTextColor
                                font.pixelSize: 24 * AppFramework.displayScaleFactor
                                Accessible.ignored: true
                            }

                            onClicked: {
                                console.log("lat:%1, lon:%2".arg(clipLat).arg(clipLon))
                                if (validateCoordinates(clipLon,clipLat)) {
                                    var newLon = clipLat;
                                    clipLat = clipLon;
                                    clipLon = newLon;
                                }
                                else{
                                    swapError.show();
                                }
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Swap coordinates")
                            Accessible.description: qsTr("Click this button to swap the coordinate values. If the swap is invalid, an alert message is displayed.")
                            Accessible.onPressAction: {
                                if (enabled && visible) {
                                    clicked(null);
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            Item {
                Layout.preferredWidth: parent.width - 32 * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 36 * scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Label {
                        Layout.preferredWidth: Math.min(implicitWidth, parent.width / 2)
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter

                        text: leftBtnString
                        visible: text > ""
                        rightPadding: 8 * scaleFactor
                        leftPadding: rightPadding

                        font.pixelSize: 14 * scaleFactor
                        font.family: dialog.fontFamily
                        font.letterSpacing: 0.75 * scaleFactor
                        font.bold: true
                        lineHeight: 19 * scaleFactor
                        lineHeightMode: Text.FixedHeight
                        color: buttonColor
                        elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dialog.visible = false
                                leftFunction();
                                clickLeft();
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 8 * scaleFactor
                    }

                    Label {
                        id: rightBtn

                        Layout.preferredWidth: Math.min(implicitWidth, parent.width / 2)
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter

                        text: rightBtnString
                        visible: text > ""
                        rightPadding: 8 * scaleFactor
                        leftPadding: rightPadding

                        font.pixelSize: 14 * scaleFactor
                        font.family: dialog.fontFamily
                        font.letterSpacing: 0.75 * scaleFactor
                        font.bold: true
                        lineHeight: 19 * scaleFactor
                        lineHeightMode: Text.FixedHeight
                        color: buttonColor
                        elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dialog.visible = false
                                rightFunction();
                                clickRight();
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * scaleFactor
            }
        }
    }
}
