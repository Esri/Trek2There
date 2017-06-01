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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0

Item {

    id: safetyWarningView

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle{
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
        Accessible.role: Accessible.Pane

        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            Rectangle{
                Layout.preferredHeight: sf(50)
                Layout.fillWidth: true
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane

                Text{
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Disclaimer")
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground

                    Accessible.role: Accessible.Heading
                    Accessible.name: text
                }


            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: sf(50)
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                Accessible.ignored: true

                Image{
                    source: "images/notice_triangle.png"
                    anchors.centerIn: parent
                    height: sf(30)
                    fillMode: Image.PreserveAspectFit
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: sf(16)
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane

                TextArea{
                    id: disclaimerText
                    property string para1: qsTr("Do not attempt to use this directional information unless you are at a complete stop. Travel safely and use common sense when using Trek2There. Trek2There is not to be used for terrain avoidance as direction and distance information does not consider traveling around physical barriers such as cliffs, water bodies, roadways, moving vehicles, buildings, etc.")
                    property string para2: qsTr("Do not follow any travel suggestions that appear to be hazardous, unsafe, or illegal.")
                    property string para3: qsTr("Please refer to the license agreement for further details.")
                    property string para4: qsTr("I understand that usage metrics may be gathered and used to make Trek2There a better application.")
                    property string esriLabsText: qsTr("Trek2There is an Esri Labs project and not an official Esri product. Trek2There is provided on an as-is-basis and you assume all risks associated with using this app. Please refer to the license agreement for further details.")

                    readOnly: true
                    anchors.fill: parent
                    textFormat: Text.RichText
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    text: "<p>%1</p><p>%2</p><p>%3</p><p>%4</p><p>%5</p>".arg(para1).arg(para2).arg(para3).arg(para4).arg(esriLabsText)
                    wrapMode: TextArea.Wrap
                    onLinkActivated: {
                         Qt.openUrlExternally(link);
                    }
                    Accessible.role: Accessible.StaticText
                    Accessible.name: qsTr("Disclaimer text")
                    Accessible.readOnly: true
                    Accessible.multiLine: true
                    Accessible.focusable: true
                }
            }
            //------------------------------------------------------------------

            Rectangle{
                Layout.preferredHeight: sf(50)
                Layout.fillWidth: true
                Layout.margins: sf(16)
                Layout.topMargin: 0
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane

                Text{
                    property string elementText: qsTr("License agreement")
                    anchors.fill: parent
                    textFormat: Text.RichText
                    text: "<a href='http://esriurl.com/labseula' style='color:#007ac2'>%1</a>".arg(elementText)
                    onLinkActivated: {
                         Qt.openUrlExternally(link);
                    }
                    Accessible.role: Accessible.Link
                    Accessible.name: elementText
                    Accessible.focusable: true
                    Accessible.onPressAction: {
                        Qt.openUrlExternally('http://esriurl.com/labseula');
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.preferredHeight: sf(50)
                Layout.fillWidth: true
                color: !nightMode ? "#ededed" : "#272727"
                visible: false // disabled for v1.0
                enabled: false // disabled for v1.0
                Accessible.role: Accessible.Pane
                Accessible.ignored: true // disabled for v1.0

                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: sf(16)
                    anchors.rightMargin: sf(16)
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Accessible.role: Accessible.Pane

                        Text{
                            id: doNotShowWarningAgainLabel
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Don't show this message again.")
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            Accessible.role: Accessible.StaticText
                            Accessible.name: text
                        }
                    }

                    Rectangle{
                        Layout.preferredWidth: parent.height
                        Layout.fillHeight: true
                        color: "transparent"
                        Accessible.role: Accessible.Pane

                        RadioButton{
                            id: doNotShowWarningAgain
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right

                            Accessible.role: Accessible.RadioButton
                            Accessible.name: doNotShowWarningAgainLabel.text
                            Accessible.checkable: true
                            Accessible.onPressAction: { /* no action required yet */ }

                            indicator: Rectangle {
                              implicitWidth: sf(20)
                              implicitHeight: sf(20)
                              radius: sf(10)
                              border.width: sf(2)
                              border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                              color: !nightMode ? "#ededed" : "#272727"
                              Rectangle {
                                  anchors.fill: parent
                                  visible: control.checked
                                  color: !nightMode ? "#595959" : nightModeSettings.foreground
                                  radius: sf(9)
                                  anchors.margins: sf(4)
                              }
                            }
                        }
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.preferredHeight: sf(50)
                Layout.fillWidth: true
                Layout.bottomMargin: sf(16)
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane

                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: sf(16)
                    anchors.rightMargin: sf(16)
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: false // disabled for v1.0
                        enabled: false // disabled for v1.0
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Accessible.role: Accessible.Pane
                        Accessible.ignored: true // disabled for v1.0

                        Button{
                            height: parent.height
                            width: parent.width - sf(50)
                            anchors.left: parent.left
                            background: Rectangle{
                                anchors.fill: parent
                                color: parent.pressed || parent.hovered ? "#fff" : ( !nightMode ? dayModeSettings.background : nightModeSettings.background )
                            }
                            Text{
                                anchors.centerIn: parent
                                color: buttonTextColor
                                text: qsTr("Cancel")
                              }
                            onClicked: {
                                Qt.quit();
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Cancel")
                            Accessible.description: qsTr("This button will close the application, if allowed by the operating system.")
                            Accessible.onPressAction: {
                                clicked(null);
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Accessible.role: Accessible.Pane

                        Button{
                            height: parent.height
                            width: parent.width // parent.width - 50 * AppFramework.displayScaleFactor
                            anchors.right: parent.right
                            background: Rectangle{
                                anchors.fill: parent
                                color: parent.pressed || parent.hovered ? "#fff" : ( !nightMode ? dayModeSettings.background : nightModeSettings.background )
                                border.color: !nightMode ? "#ddd" : nightModeSettings.secondaryBackground
                                border.width: sf(1)
                                radius: sf(5)
                            }
                            Text{
                                anchors.centerIn: parent
                                color: buttonTextColor
                                text: qsTr("Accept")
                            }

                            onClicked: {
                                /* // disabled for v1.0
                                if(doNotShowWarningAgain.checked){
                                    app.settings.setValue("showSafetyWarning", false);
                                }
                                app.settings.setValue("safteyWarningAccepted", true);
                                */
                                mainStackView.push(navigationView, {}, StackView.ReplaceTransition);
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Accept")
                            Accessible.description: qsTr("This will take you to the navigation view, if you have read and accept the disclaimer text.")
                            Accessible.onPressAction: {
                                clicked(null);
                            }
                        }
                    }
                }
            }
        }
    }
}
