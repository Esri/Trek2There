/* Copyright 2017 Esri
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

import QtQuick 2.8
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.1
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0

Dialog {
    id: clipboardDialog
    title: "Use Coordinates on Clipboard"

    property string clipLat: ""
    property string clipLon: ""

    signal useCoordinates()
    signal dismissCoordinates()

    Accessible.role: Accessible.Dialog
    Accessible.name: title
    Accessible.description: qsTr("This dialog appears when coordinates have been copied to the clipboard. It allows the user to use the coordinates in the application.")

    contentItem:  Rectangle{
        width: sf(300)
        height: sf(200)
        color: "#fff"

        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "#fff"
                Accessible.role: Accessible.Pane

                Text{
                    anchors.fill: parent
                    anchors.margins: sf(5)
                    text: qsTr("It looks like you copied coordinates to the clipboard. Do you want to use them in Trek2There?")
                    wrapMode: Text.WordWrap
                    font.pointSize: 15
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
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
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Lat (y): %1".arg(clipLat)
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("This is the latitude or y value")
                            }

                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Lng (x): %1".arg(clipLon)
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("This is the longitude or x value")
                            }

                            StatusIndicator {
                                id: swapError
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.margins: sf(5)
                                Layout.bottomMargin: 0
                                messageType: swapError.error
                                message: qsTr("Invalid coordinate swap.")
                                hideAutomatically: true
                                hideAfter: 4000
                                Accessible.role: Accessible.AlertMessage
                                Accessible.name: message

                            }
                        }
                    }

                    // ---------------------------------------------------------

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: sf(50)
                        radius: sf(5)
                        Accessible.role: Accessible.Pane

                        Button {
                            anchors.fill: parent
                            tooltip: qsTr("Swap coordinates")
                            style: ButtonStyle {
                                background: Rectangle{
                                    color: "transparent"
                                    anchors.fill: parent
                                    radius: sf(5)
                                    border.width: sf(1)
                                    border.color: buttonTextColor
                                }
                            }

                            Text {
                                font.family: icons.name
                                text: icons.swap
                                anchors.centerIn: parent
                                color: buttonTextColor
                                font.pointSize: 24
                                Accessible.ignored: true
                            }

                            onClicked: {
                                console.log("lat:%1, lon:%2".arg(clipLat).arg(clipLon))
                                if(validCoordinates(clipLon,clipLat)){
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
                                if(enabled && visible){
                                    clicked(null);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(50)
                Layout.margins: sf(5)
                Accessible.role: Accessible.Pane

                RowLayout {
                    anchors.fill: parent

                    Button {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: qsTr("No")
                        style: ButtonStyle {
                            background: Rectangle {
                                color: "transparent"
                                anchors.fill: parent
                                radius: sf(5)
                                border.width: sf(1)
                                border.color: buttonTextColor
                            }
                        }

                        onClicked: {
                            dismissCoordinates();
                            swapError.hide();
                            clipboardDialog.close();
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: qsTr("No")
                        Accessible.description: qsTr("Do not use the coordinate values copied to the clipboard.")
                        Accessible.onPressAction: {
                            if (enabled && visible) {
                                clicked(null);
                            }
                        }
                    }

                    Button {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: qsTr("Yes")
                        style: ButtonStyle {
                            background: Rectangle {
                                color: "transparent"
                                anchors.fill: parent
                                radius: sf(5)
                                border.width: sf(1)
                                border.color: buttonTextColor
                            }
                        }

                        onClicked: {
                            useCoordinates();
                            swapError.hide();
                            clipboardDialog.close();
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: qsTr("Yes")
                        Accessible.description: qsTr("Use the coordinate values copied to the clipboard.")
                        Accessible.onPressAction: {
                            if(enabled && visible) {
                                clicked(null);
                            }
                        }
                    }
                }
            }
        }
    }

    onDismissCoordinates: {
        clipLat = "";
        clipLon = "";
    }

    // END /////////////////////////////////////////////////////////////////////
}
