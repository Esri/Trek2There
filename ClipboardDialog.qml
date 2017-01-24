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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
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

    contentItem:  Rectangle{

        width: 300 * AppFramework.displayScaleFactor
        height: 250 * AppFramework.displayScaleFactor
        color: "#fff"

        ColumnLayout{
            anchors.fill: parent
            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                   color: "#fff"
                Text{
                    anchors.fill: parent
                    anchors.margins: 5 * AppFramework.displayScaleFactor
                    text: qsTr("It looks like you copied coordinates to the clipboard. Do you want to use them in Trek2There?")
                    wrapMode: Text.WordWrap
                    font.pointSize: 15
                }
            }

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "#eee"

                RowLayout{
                    anchors.fill: parent
                    anchors.margins: 5 * AppFramework.displayScaleFactor
                    spacing: 0
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "#eee"
                        ColumnLayout{
                            anchors.fill: parent
                            spacing: 0
                            Text{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Lat (y): %1".arg(clipLat)
                            }
                            Text{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Lng (x): %1".arg(clipLon)
                            }
                            StatusIndicator{
                                id: swapError
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.margins: 5 * AppFramework.displayScaleFactor
                                Layout.bottomMargin: 0
                                messageType: swapError.error
                                message: qsTr("Invalid coordinate swap.")
                                hideAutomatically: true
                                hideAfter: 4000
                            }
                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                        radius: 5 * AppFramework.displayScaleFactor

                        Button{
                            anchors.fill: parent
                            style: ButtonStyle{
                                background: Rectangle{
                                    color: "transparent"
                                    anchors.fill: parent
                                    radius: 5 * AppFramework.displayScaleFactor
                                    border.width: 1 * AppFramework.displayScaleFactor
                                    border.color: buttonTextColor
                                }
                            }

                            Text{
                                font.family: icons.name
                                text: icons.swap
                                anchors.centerIn: parent
                                color: buttonTextColor
                                font.pointSize: 24
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
                        }
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                Layout.margins: 5 * AppFramework.displayScaleFactor
                RowLayout{
                    anchors.fill: parent

                    Button{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: qsTr("No")
                        style: ButtonStyle{
                            background: Rectangle{
                                color: "transparent"
                                anchors.fill: parent
                                radius: 5 * AppFramework.displayScaleFactor
                                border.width: 1 * AppFramework.displayScaleFactor
                                border.color: buttonTextColor
                            }
                        }

                        onClicked: {
                            dismissCoordinates();
                            swapError.hide();
                            clipboardDialog.close();
                        }
                    }

                    Button{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: qsTr("Yes")
                        style: ButtonStyle{
                            background: Rectangle{
                                color: "transparent"
                                anchors.fill: parent
                                radius: 5 * AppFramework.displayScaleFactor
                                border.width: 1 * AppFramework.displayScaleFactor
                                border.color: buttonTextColor
                            }
                        }

                        onClicked: {
                            useCoordinates();
                            swapError.hide();
                            clipboardDialog.close();
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
