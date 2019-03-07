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

    title: qsTr("Information")
    icon: "images/info.png"
    description: ""

    //--------------------------------------------------------------------------

    property bool initialized
    property bool dirty: false

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
            if (dirty) {
                changed();
                dirty = false;
            }
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 10 * AppFramework.displayScaleFactor
            }

            spacing: 10 * AppFramework.displayScaleFactor

            GroupColumnLayout {
                Layout.fillWidth: true
                visible: deviceType !== kDeviceTypeInternal

                title: qsTr("Name")

                AppTextField {
                    id: deviceLabel

                    Layout.fillWidth: true

                    text: gnssSettings.knownDevices[deviceName].label > "" ? gnssSettings.knownDevices[deviceName].label : deviceName
                    placeholderText: qsTr("Custom display name")
                    textColor: foregroundColor

                    onTextChanged: {
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].label = text;
                            if (isTheActiveSensor) {
                                gnssSettings.lastUsedDeviceLabel = text;
                            }
                        }
                        dirty = true;
                    }
                }
            }

            GroupColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                title: qsTr("Details")

                RowLayout {
                    Layout.fillWidth: true

                    AppText {
                        text: qsTr("Provider Name:")
                        color: foregroundColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    AppText {
                        Layout.fillWidth: parent
                        color: foregroundColor
                        text: deviceType !== kDeviceTypeInternal ? deviceName : controller.integratedProviderName
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------
}
