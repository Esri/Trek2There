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
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0

import "./controls"
import "./CoordinateConversions.js" as CC

SettingsTab {

    title: qsTr("Antenna Height")
    icon: "images/antenna_height.png"
    description: ""

    //--------------------------------------------------------------------------

    property bool initialized

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

    signal changed()

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {
            initialized = true;
        }

        Component.onDestruction: {
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 10 * AppFramework.displayScaleFactor
            }

            spacing: 10 * AppFramework.displayScaleFactor

            GroupColumnLayout {
                Layout.fillWidth: true

                title: qsTr("Antenna height of receiver")

                AppText {
                    Layout.fillWidth: true

                    text: qsTr("The distance from the antenna to the ground surface is subtracted from altitude values.")
                    color: foregroundColor
                }

                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200 * AppFramework.displayScaleFactor
                    Layout.maximumHeight: Layout.preferredHeight

                    source: "images/Antenna_Height.svg"
                    fillMode: Image.PreserveAspectFit
                }

                AppNumberField {
                    id: antennaHeightField

                    Layout.fillWidth: true

                    suffixText: CC.localeLengthSuffix(locale)

                    value: CC.toLocaleLength(gnssSettings.knownDevices[deviceName].antennaHeight, locale)

                    onValueChanged: {
                        var val = CC.fromLocaleLength(value, locale)
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].antennaHeight = val;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAntennaHeight = val;
                            }
                        }
                        changed();
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    //--------------------------------------------------------------------------
}
