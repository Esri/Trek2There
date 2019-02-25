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

SettingsTab {

    title: qsTr("Altitude")
    icon: "images/mountain.png"
    description: ""

    //--------------------------------------------------------------------------

    property bool initialized

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName
    readonly property string altitudeTypeMSLLabel: qsTr("Altitude above mean sea level")
    readonly property string altitudeTypeHAELabel: qsTr("Height above ellipsoid")

    signal changed()

    //--------------------------------------------------------------------------

    Item {

        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {

            var altitudeType = gnssSettings.knownDevices[deviceName].altitudeType;

            if (altitudeType === gnssSettings.kAltitudeTypeMSL) {
                mslButton.checked = true;
            }

            if (altitudeType === gnssSettings.kAltitudeTypeHAE) {
                haeButton.checked = true;
            }

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

                title: qsTr("Altitude type")

                AppRadioButton {
                    id: mslButton

                    Layout.fillWidth: true

                    text: altitudeTypeMSLLabel

                    onCheckedChanged: {
                        if (initialized && !gnssSettings.updating && checked) {
                            haeButton.checked = false;
                            gnssSettings.knownDevices[deviceName].altitudeType = gnssSettings.kAltitudeTypeMSL;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAltitudeType = gnssSettings.kAltitudeTypeMSL;
                            }
                        }
                        changed();
                    }
                }

                AppRadioButton {
                    id: haeButton

                    Layout.fillWidth: true

                    text: altitudeTypeHAELabel

                    onCheckedChanged: {
                        if (initialized && !gnssSettings.updating && checked) {
                            mslButton.checked = false;
                            gnssSettings.knownDevices[deviceName].altitudeType = gnssSettings.kAltitudeTypeHAE;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAltitudeType = gnssSettings.kAltitudeTypeHAE;
                            }
                        }
                        changed();
                    }
                }
            }

            GroupColumnLayout {
                visible: mslButton.checked

                Layout.fillWidth: true

                title: qsTr("Geoid separation")

                AppText {
                    Layout.fillWidth: true

                    text: qsTr('The distance <font color="#e04f1d"><b>N</b></font> from the surface on an ellipsoid <font color="#6db5e3"><b>E</b></font> to the surface of the geoid (or mean sea level) <font color="#68aa67"><b>G</b></font>, measured along a line perpendicular to the ellipsoid. <font color="#e04f1d"><b>N</b></font> is positive if the geoid lies above the ellipsoid, negative if it lies below.')
                }

                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200 * AppFramework.displayScaleFactor
                    Layout.maximumHeight: Layout.preferredHeight

                    source: "images/Geoid_Separation.svg"
                    fillMode: Image.PreserveAspectFit
                }

                NumberField {
                    id: geoidSeparationField

                    Layout.fillWidth: true

                    suffixText: localeLengthSuffix(locale)

                    value: toLocaleLength(gnssSettings.knownDevices[deviceName].geoidSeparation, locale)

                    onValueChanged: {
                        var val = fromLocaleLength(value, locale)
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].geoidSeparation = val;
                            if (isTheActiveSensor) {
                                gnssSettings.locationGeoidSeparation = val;
                            }
                        }
                        changed();
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Accessible.ignored: true
            }
        }
    }

    //--------------------------------------------------------------------------
}
