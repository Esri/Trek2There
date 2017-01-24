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
import QtQml 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtPositioning 5.4

import ArcGIS.AppFramework 1.0

Item {
    id: settingsView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property var distanceFormats: ["Decimal degrees", "Degrees, minues and seconds", "Degrees and decimal minutes", "MGRS", "US national degrees"]
    property int currentDistanceFormat: 0
    property var currentDestination: null
    property int sideMargin: 14 * AppFramework.displayScaleFactor

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
        Accessible.role: Accessible.Pane

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                id: navBAr
                color: nightMode ===false ? dayModeSettings.background : nightModeSettings.background
                Accessible.role: Accessible.Pane
                Accessible.name: qsTr("Navigation bar")

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Accessible.role: Accessible.Pane

                    Rectangle {
                        id: backButtonContainer
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                        Accessible.role: Accessible.Pane

                        Button {
                            anchors.fill: parent
                            style: ButtonStyle {
                                background: Rectangle {
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                    anchors.fill: parent

                                    Image {
                                        id: backArrow
                                        source: "images/back_arrow.png"
                                        anchors.left: parent.left
                                        anchors.leftMargin: sideMargin
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - (30 * AppFramework.displayScaleFactor)
                                        fillMode: Image.PreserveAspectFit
                                        Accessible.ignored: true
                                    }
                                    ColorOverlay {
                                        source: backArrow
                                        anchors.fill: backArrow
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        Accessible.ignored: true
                                    }
                                }
                            }

                            onClicked: {
                                var previousItem = mainStackView.get( settingsView.Stack.index - 1 );
                                if(destinationLatitude.acceptableInput && destinationLongitude.acceptableInput){
                                    requestedDestination = (destinationLatitude.length > 0  && destinationLongitude.length > 0) ? QtPositioning.coordinate(destinationLatitude.text, destinationLongitude.text) : null;
                                }
                                Qt.inputMethod.hide();

                                mainStackView.push( { item: previousItem } );
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Go back")
                            Accessible.description: qsTr("Go back to Navigation View")
                            Accessible.onPressAction: {
                                clicked();
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
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Settings")
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            Accessible.role: Accessible.Heading
                            Accessible.name: text
                        }
                    }

                    Rectangle {
                        id: aboutButtonContainer
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                        Accessible.role: Accessible.Pane

                        Button {
                            anchors.fill: parent
                            style: ButtonStyle {
                                background: Rectangle {
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                    anchors.fill: parent

                                    Image {
                                        id: aboutIcon
                                        source: "images/about.png"
                                        anchors.left: parent.left
                                        anchors.leftMargin: sideMargin
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - (30 * AppFramework.displayScaleFactor)
                                        fillMode: Image.PreserveAspectFit
                                        Accessible.ignored: true
                                    }
                                    ColorOverlay {
                                        source: aboutIcon
                                        anchors.fill: aboutIcon
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        Accessible.ignored: true
                                    }
                                }
                            }

                            onClicked: {
                                mainStackView.push(aboutView);
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("About the app")
                            Accessible.description: qsTr("This button will take you to the About view.")
                            Accessible.onPressAction: {
                                clicked();
                            }
                        }
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                Accessible.role: Accessible.Pane

                Flickable {
                    width: parent.width
                    height: parent.height
                    contentHeight: contentItem.children[0].childrenRect.height
                    contentWidth: parent.width
                    interactive: true
                    flickableDirection: Flickable.VerticalFlick
                    clip: true
                    Accessible.role: Accessible.Pane

                    ColumnLayout {
                        anchors.fill: parent
                        spacing:0
                        Accessible.role: Accessible.Pane

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: "transparent"
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("DESTINATION")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Enter your destination latitude and longitude below and then hit the back button to start navigation.")
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.bottomMargin: 2 * AppFramework.displayScaleFactor
                            color: !nightMode ? "#fff" : nightModeSettings.background
                            visible: false // OFF FOR V1.0
                            enabled: false // OFF FOR V1.0
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true // OFF FOR V1.0

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0
                                Accessible.role: Accessible.Pane

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 120 * AppFramework.displayScaleFactor
                                    text: qsTr("Format")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    Accessible.role: Accessible.Heading
                                    Accessible.ignored: true // OFF FOR V1.0
                                    Accessible.name: text
                                }

                                Button {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    style: ButtonStyle {
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: !nightMode ? "#fff" : nightModeSettings.background

                                            Text {
                                                anchors.fill: parent
                                                anchors.leftMargin: 5 * AppFramework.displayScaleFactor
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignLeft
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                                text: distanceFormats[currentDistanceFormat]
                                            }
                                        }
                                    }

                                    onClicked: {
                                        // TODO Provide dialog to change format
                                    }

                                    Accessible.role: Accessible.Button
                                    Accessible.ignored: true // OFF FOR V1.0
                                    Accessible.name: qsTr("Change coordinate format")
                                    Accessible.description: qsTr("Change the format of the coordiante entry. For example decimal degrees to MGRS.")
                                    Accessible.onPressAction: {
                                        clicked();
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.bottomMargin: 2 * AppFramework.displayScaleFactor
                            color: !nightMode ? "#fff" : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0
                                Accessible.role: Accessible.Pane

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 120 * AppFramework.displayScaleFactor
                                    text: qsTr("Latitude")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    Accessible.role: Accessible.Heading
                                    Accessible.name: text
                                }

                                TextField {
                                    id: destinationLatitude
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    placeholderText: qsTr("Enter latitude")
                                    text: (requestedDestination === null) ? "" : requestedDestination.latitude
                                    inputMethodHints: Qt.ImhPreferNumbers
                                    validator: latitudeValidator
                                    style: TextFieldStyle {
                                        background: Rectangle {
                                            anchors.fill: parent
                                            anchors.topMargin: 3 * AppFramework.displayScaleFactor
                                            anchors.bottomMargin: 3 * AppFramework.displayScaleFactor
                                            border.width: 1 * AppFramework.displayScaleFactor
                                            border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                            color: dayModeSettings.background
                                        }
                                        textColor: dayModeSettings.foreground
                                    }

                                    Accessible.role: Accessible.EditableText
                                    Accessible.name: qsTr("Enter latitude")
                                    Accessible.description: qsTr("Enter the latitude of your desired destination here.")
                                    Accessible.editable: true
                                    Accessible.focusable: true
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: !nightMode ? "#fff" : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0
                                Accessible.role: Accessible.Pane

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 120 * AppFramework.displayScaleFactor
                                    text: qsTr("Longitude")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    Accessible.role: Accessible.Heading
                                    Accessible.name: text
                                }
                                TextField {
                                    id: destinationLongitude
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    placeholderText: qsTr("Enter longitude")
                                    text: (requestedDestination === null) ? "" : requestedDestination.longitude
                                    inputMethodHints: Qt.ImhPreferNumbers
                                    validator: longitudeValidator
                                    style: TextFieldStyle {
                                        background: Rectangle {
                                            anchors.fill: parent
                                            anchors.topMargin: 3 * AppFramework.displayScaleFactor
                                            anchors.bottomMargin: 3 * AppFramework.displayScaleFactor
                                            border.width: 1 * AppFramework.displayScaleFactor
                                            border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                            color: dayModeSettings.background
                                        }
                                        textColor: dayModeSettings.foreground
                                    }

                                    Accessible.role: Accessible.EditableText
                                    Accessible.name: qsTr("Enter longitude")
                                    Accessible.description: qsTr("Enter the longitude of your desired destination here.")
                                    Accessible.editable: true
                                    Accessible.focusable: true
                                }
                            }
                        }


                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.topMargin: 8 * AppFramework.displayScaleFactor
                            Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                            color: "transparent"
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("DISTANCE UNIT")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Select the desired unit of measure from the following choices.")
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            Button {
                                anchors.fill: parent
                                style: ButtonStyle {
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0
                                            anchors.leftMargin: sideMargin
                                            anchors.rightMargin: sideMargin

                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                                RadioButton{
                                                    id: metricChecked
                                                    anchors.centerIn: parent
                                                    width: parent.width - (30 * AppFramework.displayScaleFactor)
                                                    checked: usesMetric === true
                                                    Accessible.ignored: true
                                                    style: RadioButtonStyle {
                                                      indicator: Rectangle {
                                                          implicitWidth: 20 * AppFramework.displayScaleFactor
                                                          implicitHeight: 20 * AppFramework.displayScaleFactor
                                                          radius: 10 * AppFramework.displayScaleFactor
                                                          border.width: 2 * AppFramework.displayScaleFactor
                                                          border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                                          color: !nightMode ? "#ededed" : "#272727"
                                                          Rectangle {
                                                              anchors.fill: parent
                                                              visible: control.checked
                                                              color: !nightMode ? "#595959" : nightModeSettings.foreground
                                                              radius: 9 * AppFramework.displayScaleFactor
                                                              anchors.margins: 4 * AppFramework.displayScaleFactor
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            Text {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.leftMargin: sideMargin
                                                text: qsTr("Metric")
                                                verticalAlignment: Text.AlignVCenter
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                                Accessible.ignored: true
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    usesMetric = true;
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: qsTr("Use Metric")
                                Accessible.description: qsTr("Use metric system for the distance unit displayed")
                                Accessible.onPressAction: {
                                    clicked();
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            Button {
                                anchors.fill: parent
                                style: ButtonStyle {
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0
                                            anchors.leftMargin: sideMargin
                                            anchors.rightMargin: sideMargin

                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                                RadioButton{
                                                    id: imperialChecked
                                                    anchors.centerIn: parent
                                                    width: parent.width - (30 * AppFramework.displayScaleFactor)
                                                    checked: usesMetric === false
                                                    Accessible.ignored: true
                                                    style: RadioButtonStyle {
                                                      indicator: Rectangle {
                                                          implicitWidth: 20 * AppFramework.displayScaleFactor
                                                          implicitHeight: 20 * AppFramework.displayScaleFactor
                                                          radius: 10 * AppFramework.displayScaleFactor
                                                          border.width: 2 * AppFramework.displayScaleFactor
                                                          border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                                          color: !nightMode ? "#ededed" : "#272727"
                                                          Rectangle {
                                                              anchors.fill: parent
                                                              visible: control.checked
                                                              color: !nightMode ? "#595959" : nightModeSettings.foreground
                                                              radius: 9 * AppFramework.displayScaleFactor
                                                              anchors.margins: 4 * AppFramework.displayScaleFactor
                                                          }
                                                      }
                                                  }
                                                }
                                            }
                                            Text {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.leftMargin: sideMargin
                                                text: qsTr("Imperial")
                                                verticalAlignment: Text.AlignVCenter
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                                Accessible.ignored: true
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    usesMetric = false;
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: qsTr("Use Imperial")
                                Accessible.description: qsTr("Use the imperial system for the distance unit displayed")
                                Accessible.onPressAction: {
                                    clicked();
                                }
                            }
                        }

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.topMargin: 10 * AppFramework.displayScaleFactor
                            visible: false
                            enabled: false
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                            Button {
                                anchors.fill: parent
                                style: ButtonStyle {
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0
                                            anchors.leftMargin: sideMargin
                                            anchors.rightMargin: sideMargin

                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                                                Image {
                                                    id: useOuterArrowCheckmark
                                                    anchors.centerIn: parent
                                                    width: parent.width - (30 * AppFramework.displayScaleFactor)
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: useDirectionOfTravelCircle === true ? true : false
                                                    source: "images/checkmark.png"
                                                    Accessible.ignored: true
                                                }
                                            }
                                            Text {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.leftMargin: sideMargin
                                                text: qsTr("Use outer arrow")
                                                verticalAlignment: Text.AlignVCenter
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                                Accessible.ignored: true
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    useDirectionOfTravelCircle = (useDirectionOfTravelCircle === false) ? true : false;
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: qsTr("Toggle outer arrow on or off")
                                Accessible.onPressAction: {
                                    clicked();
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            Accessible.ignored: true
                        }


                        //------------------------------------------------------

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            color: "transparent"
                            Accessible.ignored: true
                        }
                    } // end contentItem
                } // end flicable
            }
        }

        //------------------------------------------------------------------
    }
}
