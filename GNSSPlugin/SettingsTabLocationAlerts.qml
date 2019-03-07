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
import ArcGIS.AppFramework.Notifications 1.0

import "./controls"

SettingsTab {

    title: qsTr("Alerts")
    icon: "images/exclamation-mark-triangle.png"
    description: ""

    //--------------------------------------------------------------------------

    property bool initialized

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName
    readonly property string kBanner: qsTr("Visual")
    readonly property string kVoice: qsTr("Audio")
    readonly property string kVibrate: qsTr("Vibrate")
    readonly property string kNone: qsTr("Off")

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

                title: qsTr("Styles")

                AppText {
                    Layout.fillWidth: true

                    text: qsTr("Alerts are triggered when the status of your connection changes. This includes receiver disconnection or data not being received. The alert style is how alerts are presented to you in the app.")
                    color: foregroundColor
                }

                AppSwitch {
                    id: visualSwitch

                    Layout.fillWidth: true

                    checked: gnssSettings.knownDevices[deviceName].locationAlertsVisual

                    text: qsTr("Visual")

                    onCheckedChanged: {
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].locationAlertsVisual = checked;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAlertsVisual = checked;
                            }
                        }
                        changed();
                    }
                }

                AppSwitch {
                    id: speechSwitch

                    Layout.fillWidth: true

                    checked: gnssSettings.knownDevices[deviceName].locationAlertsSpeech

                    text: qsTr("Audio")

                    onCheckedChanged: {
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].locationAlertsSpeech = checked;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAlertsSpeech = checked;
                            }
                        }
                        changed();
                    }
                }

                AppSwitch {
                    id: vibrateSwitch

                    Layout.fillWidth: true

                    enabled: Vibration.supported
                    checked: gnssSettings.knownDevices[deviceName].locationAlertsVibrate

                    text: qsTr("Vibrate")

                    onCheckedChanged: {
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].locationAlertsVibrate = checked;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAlertsVibrate = checked;
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
