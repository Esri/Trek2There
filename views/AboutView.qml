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
import QtQml 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

import ArcGIS.AppFramework 1.0

Item {
    id: aboutView

    // UI //////////////////////////////////////////////////////////////////////

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 22 * AppFramework.displayScaleFactor
    property bool bold: false

    Rectangle {
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
        Accessible.role: Accessible.Pane

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(50)
                id: navBar
                color: nightMode === false ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane
                Accessible.name: qsTr("Navigation bar")

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    Rectangle {
                        id: backButtonContainer

                        Layout.fillHeight: true
                        Layout.preferredWidth: sf(50)
                        Accessible.role: Accessible.Pane

                        Button {
                            anchors.fill: parent

                            background: Rectangle {
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                anchors.fill: parent
                            }

                            Image {
                                id: backArrow

                                source: "../images/back_arrow.png"
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                Accessible.ignored: true
                            }

                            ColorOverlay {
                                source: backArrow
                                anchors.fill: backArrow
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.ignored: true
                            }

                            onClicked: {
                                mainStackView.pop();
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Go back")
                            Accessible.description: qsTr("Go back to previous view")
                            Accessible.onPressAction: {
                                clicked(null);
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Accessible.role: Accessible.Pane

                        Text {
                            anchors.fill: parent
                            anchors.rightMargin: backButtonContainer.width
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            text: qsTr("About")
                            font {
                                family: aboutView.fontFamily
                                pixelSize: aboutView.pixelSize
                                bold: aboutView.bold
                            }

                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground

                            Accessible.role: Accessible.Heading
                            Accessible.name: text
                        }
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: sf(16)
                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                Accessible.role: Accessible.Pane

                ColumnLayout {
                    anchors.fill: parent
                    spacing:0
                    Accessible.role: Accessible.Pane

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.preferredHeight: sf(30)
                        Layout.bottomMargin: sf(5)
                        Layout.fillWidth: true
                        color: "transparent"
                        Accessible.role: Accessible.Pane

                        Text {
                            property string elementText: qsTr("DESCRIPTION")
                            anchors.fill: parent
                            textFormat: Text.RichText
                            text: "<b>%1</b>".arg(elementText)
                            verticalAlignment: Text.AlignBottom
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            Accessible.role: Accessible.Heading
                            Accessible.name: elementText
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Flickable {
                            id: view
                            anchors.fill: parent
                            contentHeight: descriptionText.height
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            leftMargin: 0
                            rightMargin: 0

                            TextArea {
                                id: descriptionText
                                property string esriLabsText: qsTr("Trek2There is an Esri Labs project and not an official Esri product. Trek2There is provided on an as-is-basis and you assume all risks associated with using this app. Please refer to the license agreement for further details.")
                                width: parent.width
                                readOnly: true
                                leftPadding: 0
                                rightPadding: 0
                                wrapMode: TextArea.Wrap
                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                text: "<p>%1</p><p>%2</p>".arg(app.info.description).arg(esriLabsText)
                                Accessible.role: Accessible.StaticText
                                Accessible.name: qsTr("Description text")
                                Accessible.readOnly: true
                                Accessible.multiLine: true
                            }
                        }
                    }

                    //----------------------------------------------------------

                    Item {
                        Layout.preferredHeight: sf(50)
                        Layout.bottomMargin: sf(5)
                        Layout.fillWidth: true
                        Accessible.role: Accessible.Pane

                        Text {
                            property string elementText: qsTr("ACCESS AND USE CONSTRAINTS")
                            anchors.fill: parent
                            textFormat: Text.RichText
                            text: "<b>%1</b>".arg(elementText)
                            verticalAlignment: Text.AlignBottom
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            Accessible.role: Accessible.Heading
                            Accessible.name: elementText
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: sf(50)
                        Layout.fillWidth: true
                        Layout.topMargin: 0
                        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                        Accessible.role: Accessible.Pane

                        Text {
                            anchors.fill: parent
                            textFormat: Text.RichText
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            text: qsTr("<a href='http://esriurl.com/labseula' style='color:#007ac2'>View the license agreement</a> ")
                            onLinkActivated: {
                                 Qt.openUrlExternally(link);
                            }
                            Accessible.role: Accessible.Link
                            Accessible.name: qsTr("View the license agreement.")
                            Accessible.description: qsTr("Click link in this text element to view the Esri Labs EULA via a web browser.")
                            Accessible.focusable: true
                        }
                    }

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.preferredHeight: sf(50)
                        Layout.fillWidth: true
                        Layout.topMargin: 0
                        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                        Accessible.role: Accessible.Pane

                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: {
                                logTreks = logTreks === false ? true : false;
                                if (logTreks) {
                                    logTreksIndicator.text = "<b>+</b>";
                                } else {
                                    logTreksIndicator.text = "<b>-</b>";
                                }
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Toggle logging of treks on or off. Logging is currently: %1".arg(logTreks ? "on" : "off"))
                            Accessible.description: qsTr("This is a hidden mouse or touch area that allows a user to turn logging of treks on or off. It should be turned on with caution as it may create large sqllite databases on the device.")
                            Accessible.focusable: true
                            Accessible.onPressAction: {
                                pressAndHold(null);
                            }
                        }

                        RowLayout {
                            id: appRow1

                            spacing:0

                            Text {
                                id: softwareVersion

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignLeft

                                text: "<b>App Version: %1.%2.%3</b>".arg(app.info.value("version").major).arg(app.info.value("version").minor).arg(app.info.value("version").micro)
                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.StaticText
                                Accessible.name: qsTr("Current version of the application is %1".arg(text))
                            }

                            Text {
                                id: logTreksIndicator

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight

                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Indicator
                                Accessible.name: qsTr("Indicates if logging of treks is on or off. Logging is currently: %1".arg(logTreks ? "on" : "off"))
                                Accessible.description: qsTr("If the text reads '+' then logging is turned on. If text reads '-' then logging is turned off.")
                            }
                        }

                        RowLayout {
                            id: appRow2

                            anchors.top: appRow1.bottom
                            spacing:0

                            Text {
                                id: frameworkVersion

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignLeft

                                text: qsTr("<b>AppFramework Version: </b>")
                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.StaticText
                                Accessible.name: qsTr("Current version of the application framework %1".arg(frameworkVersionNumber.text))
                            }

                            Text {
                                id: frameworkVersionNumber

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignLeft

                                text: "<b>%1</b>".arg(AppFramework.version)
                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.name: qsTr("Current version of the application framework %1".arg(frameworkVersionNumber.text))
                                Accessible.role: Accessible.StaticText
                            }
                        }

                        RowLayout {
                            anchors.top: appRow2.bottom
                            spacing:0

                            Text {
                                id: qtVersion

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignLeft

                                text: qsTr("<b>Qt Version: </b>")
                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.StaticText
                                Accessible.name: qsTr("Current version of the Qt framework %1".arg(qtVersionNumber.text))
                            }

                            Text {
                                id: qtVersionNumber

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignLeft

                                text: "<b>%1</b>".arg(AppFramework.qtVersion)
                                textFormat: Text.RichText
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.name: qsTr("Current version of the Qt framework %1".arg(qtVersionNumber.text))
                                Accessible.role: Accessible.StaticText
                            }
                        }
                    }
                }
            }
            //------------------------------------------------------------------
        }
    }
}
