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
import QtQml 2.2
import QtQuick.Controls 2.1
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
    property int sideMargin: sf(14)

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
                Layout.preferredHeight: sf(50)
                id: navBAr
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
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
                                source: "images/back_arrow.png"
                                anchors.left: parent.left
                                anchors.leftMargin: sideMargin
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - sf(30)
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
                                var previousItem = mainStackView.get( settingsView.StackView.index - 1 );
                                if(destinationLatitude.acceptableInput && destinationLongitude.acceptableInput){
                                    requestedDestination = (destinationLatitude.length > 0  && destinationLongitude.length > 0) ? QtPositioning.coordinate(destinationLatitude.text, destinationLongitude.text) : null;
                                }
                                Qt.inputMethod.hide();

                                mainStackView.push( previousItem );
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
                        Layout.preferredWidth: sf(50)
                        Accessible.role: Accessible.Pane

                        Button {
                            anchors.fill: parent
                            background: Rectangle {
                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                anchors.fill: parent
                            }
                            Image {
                                id: aboutIcon
                                source: "images/about.png"
                                anchors.left: parent.left
                                anchors.leftMargin: sideMargin
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - sf(30)
                                fillMode: Image.PreserveAspectFit
                                Accessible.ignored: true
                            }
                            ColorOverlay {
                                source: aboutIcon
                                anchors.fill: aboutIcon
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.ignored: true
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
                            Layout.preferredHeight: sf(50)
                            Layout.bottomMargin: sf(5)
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
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.bottomMargin: sf(2)
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
                                    Layout.preferredWidth: sf(120)
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
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? "#fff" : nightModeSettings.background
                                    }
                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: sf(5)
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignLeft
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        text: distanceFormats[currentDistanceFormat]
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
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.bottomMargin: sf(2)
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
                                    Layout.preferredWidth: sf(120)
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
                                    background: Rectangle {
                                        anchors.fill: parent
                                        anchors.topMargin: sf(3)
                                        anchors.bottomMargin: sf(3)
                                        border.width: sf(1)
                                        border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                        color: dayModeSettings.background
                                    }
                                    color: dayModeSettings.foreground
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
                            Layout.preferredHeight: sf(50)
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
                                    Layout.preferredWidth: sf(120)
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
                                    background: Rectangle {
                                        anchors.fill: parent
                                        anchors.topMargin: sf(3)
                                        anchors.bottomMargin: sf(3)
                                        border.width: sf(1)
                                        border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                        color: dayModeSettings.background
                                    }
                                    color: dayModeSettings.foreground

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
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.topMargin: sf(8)
                            Layout.bottomMargin: sf(5)
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

                        ButtonGroup {
                            id: distanceMeasurementGroup
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            RadioButton{
                                id: metricChecked
                                anchors.fill: parent
                                checked: usesMetric
                                Accessible.ignored: true
                                ButtonGroup.group: distanceMeasurementGroup

                                indicator: Rectangle {
                                  implicitWidth: sf(20)
                                  implicitHeight: sf(20)
                                  x: sideMargin
                                  y: parent.height / 2 - height / 2
                                  radius: sf(10)
                                  border.width: sf(2)
                                  border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                  color: !nightMode ? "#ededed" : "#272727"
                                      Rectangle {
                                          anchors.fill: parent
                                          visible: parent.parent.checked
                                          color: !nightMode ? "#595959" : nightModeSettings.foreground
                                          radius: sf(9)
                                          anchors.margins: sf(4)
                                      }
                                }
                                contentItem: Text {
                                        opacity: enabled ? 1.0 : 0.3
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        text: qsTr("Metric")
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: metricChecked.indicator.width + metricChecked.spacing + sideMargin
                               }
                                onCheckedChanged: {
                                    if (checked){
                                        usesMetric = true;
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane

                            RadioButton{
                                id: imperialChecked
                                anchors.fill: parent
                                checked: !usesMetric
                                Accessible.ignored: true
                                ButtonGroup.group: distanceMeasurementGroup

                                indicator: Rectangle {
                                  implicitWidth: sf(20)
                                  implicitHeight: sf(20)
                                  x: sideMargin
                                  y: parent.height / 2 - height / 2
                                  radius: sf(10)
                                  border.width: sf(2)
                                  border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                  color: !nightMode ? "#ededed" : "#272727"
                                      Rectangle {
                                          anchors.fill: parent
                                          visible: parent.parent.checked
                                          color: !nightMode ? "#595959" : nightModeSettings.foreground
                                          radius: sf(9)
                                          anchors.margins: sf(4)
                                      }
                                }
                                contentItem: Text {
                                        opacity: enabled ? 1.0 : 0.3
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        text: qsTr("Imperial")
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: imperialChecked.indicator.width + imperialChecked.spacing + sideMargin
                               }
                                onCheckedChanged: {
                                    if (checked){
                                        usesMetric = false;
                                    }
                                }
                            }
                        }

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.topMargin: sf(8)
                            Layout.bottomMargin: sf(5)
                            color: "transparent"
                            Accessible.role: Accessible.Pane
                            visible: true

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("EXPERIMENTAL FEATURES")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Turn experimental features on or off. This will enable compass assisted navigation for walking and provide a visual marker on the head up display horizon that denotes yoru destination.")
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: sf(40)
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                            Button {
                                anchors.fill: parent
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Item {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: sf(18)
                                        Layout.leftMargin: sideMargin

                                        Rectangle {
                                            width: parent.width
                                            height: width
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: !nightMode ? "#ededed" : "#272727"
                                            border.width: sf(2)
                                            border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                            Image {
                                                anchors.centerIn: parent
                                                width: parent.width - sf(8)
                                                fillMode: Image.PreserveAspectFit
                                                visible: useExperimentalFeatures
                                                source: "images/checkmark.png"
                                                Accessible.ignored: true
                                            }
                                        }
                                    }
                                    Text {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.leftMargin: sideMargin
                                        text: qsTr("Use experimental features")
                                        verticalAlignment: Text.AlignVCenter
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        Accessible.ignored: true
                                    }
                                }

                                onClicked: {
                                    useExperimentalFeatures = !useExperimentalFeatures ? true : false;
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: qsTr("Use experimental features")
                                Accessible.onPressAction: {
                                    clicked();
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: xFeaturesText.contentHeight
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            Accessible.role: Accessible.Pane
                            Accessible.ignored: true

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    anchors.leftMargin: sideMargin
                                    anchors.rightMargin: sideMargin

                                    Item {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: sf(18)
                                    }

                                    Text {
                                        id: xFeaturesText

                                        property var feedbackEmail: (function(){
                                            if (Qt.platform.os === "ios") {
                                                return "support+f9c5dcb8b61d48e88b9a784ce59feac2@feedback.hockeyapp.net";
                                            }
                                            else if (Qt.platform.os === "android") {
                                                return "support+244a6f679d574cbab4532849cdbf9e06@feedback.hockeyapp.net";
                                            }
                                            else if (Qt.platform.os === "windows" || Qt.platform.os === "winrt") {
                                                return "support+270310d21ec14a93acf5a41cf1bad33d@feedback.hockeyapp.net";
                                            }
                                            else {
                                                return "jayson_ward@esri.com";
                                            }
                                        })()

                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.bottomMargin: sf(20)
                                        Layout.leftMargin: sideMargin
                                        text: "Current experimental features include use of compass to establish course correction at walking speed and display of location pin on the head up display horizon. Esri Labs encourages users to use these features and provide feedback.<br><br>Please <a href='mailto:%1'>email us</a> with your feedback.<br>".arg(feedbackEmail)
                                        verticalAlignment: Text.AlignVCenter
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        opacity: .8
                                        Accessible.ignored: true
                                        font.pointSize: 10
                                        wrapMode: Text.Wrap
                                        textFormat: Text.StyledText
                                        linkColor: "#007ac2"

                                        onLinkActivated: {
                                            console.log(link);
                                            Qt.openUrlExternally(link);
                                        }
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
                            Layout.preferredHeight: sf(50)
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
