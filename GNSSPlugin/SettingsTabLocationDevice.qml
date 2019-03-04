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
import QtQuick.Controls 1.4

import ArcGIS.AppFramework 1.0

import "./controls"

SettingsTab {
    id: sensorDeviceTab

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""
    property var deviceProperties: null

    signal selectInternal()
    signal updateViewAndDelegate()

    //--------------------------------------------------------------------------

    onUpdateViewAndDelegate: {
        var deviceLabel = gnssSettings.knownDevices[deviceName].label > "" ? gnssSettings.knownDevices[deviceName].label : deviceName;
        if (stackView.currentItem.settingsItem.objectName === sensorDeviceTab.deviceName) {
            stackView.currentItem.title = deviceLabel;
        }
        sensorDeviceTab.deviceLabel = deviceLabel;
    }

    //--------------------------------------------------------------------------

    Item {

        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {
            controller.onDetailedSettingsPage = controller.useInternalGPS ? gnssSettings.kInternalPositionSourceName !== deviceName : controller.currentName !== deviceName;
            objectName = deviceName;
            updateDescriptions();
        }

        Component.onDestruction: {
            controller.onDetailedSettingsPage = false;
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 5 * AppFramework.displayScaleFactor

            Accessible.role: Accessible.Pane

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Accessible.role: Accessible.Pane

                ListTabView {
                    id: devicesTabView

                    anchors.fill: parent

                    delegate: settingsDelegate

                    SettingsTabLocationAboutDevice {
                        id: sensorAbout
                        onChanged: {
                            updateViewAndDelegate();
                            _item.updateDescriptions();
                        }
                    }

                    SettingsTabLocationAlerts {
                        id: sensorAlerts
                        onChanged: {
                            _item.updateDescriptions();
                        }
                    }

                    SettingsTabLocationAntennaHeight {
                        id: sensorAntennaHeight
                        onChanged: {
                            _item.updateDescriptions();
                        }
                    }

                    SettingsTabLocationAltitude {
                        id: sensorAltitude
                        onChanged: {
                            _item.updateDescriptions();
                        }
                    }

                    SettingsTabContainer {
                        id: settingsTabContainer
                    }

                    onSelected: {
                        stackView.push(settingsTabContainer,
                                             {
                                                 settingsTab: item,
                                                 title: item.title,
                                                 settingsComponent: item.contentComponent,
                                             });
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 44 * AppFramework.displayScaleFactor
                Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                visible: deviceType !== kDeviceTypeInternal

                Accessible.role: Accessible.Pane

                StyledButton {
                    id: removeDeviceButton

                    backgroundColor: locationSettingsTab.backgroundColor
                    textColor: locationSettingsTab.foregroundColor
                    hoveredBackgroundColor: locationSettingsTab.hoverBackgroundColor
                    borderColor: locationSettingsTab.dividerColor

                    text: qsTr("Remove %1").arg(deviceLabel > "" ? deviceLabel : deviceName)
                    fontFamily: locationSettingsTab.fontFamily

                    anchors{
                        fill: parent
                        leftMargin: 15 * AppFramework.displayScaleFactor
                        rightMargin: 15 * AppFramework.displayScaleFactor
                    }

                    enabled: deviceType !== kDeviceTypeInternal

                    onClicked: {
                        confirmDeletionDialog.confirmDeletion();
                    }
                }
            }
        }

        //--------------------------------------------------------------------------

        Component {
            id: settingsDelegate

            SettingsTabDelegate {
                listTabView: devicesTabView
                foregroundColor: locationSettingsTab.foregroundColor
                hoverBackgroundColor: locationSettingsTab.hoverBackgroundColor
                fontFamily: locationSettingsTab.fontFamily
            }
        }

        //--------------------------------------------------------------------------

        ConfirmPanel {
            id: confirmDeletionDialog

            function confirmDeletion() {
                confirmDeletionDialog.clear();
                confirmDeletionDialog.icon = "images/warning.png";
                confirmDeletionDialog.title = qsTr("Remove");
                confirmDeletionDialog.text = qsTr("This action will remove the selected location provider");
                confirmDeletionDialog.question = qsTr("Are you sure you want to remove this provider?")
                confirmDeletionDialog.show(deleteProvider);
            }

            function deleteProvider() {
                // If this is the currently connected device, select the internal
                if (controller.currentName === sensorDeviceTab.deviceName) {
                    selectInternal();
                }

                gnssSettings.deleteKnownDevice(sensorDeviceTab.deviceName);
                stackView.pop();
            }
        }

        //--------------------------------------------------------------------------

        function updateDescriptions(){

            var props = gnssSettings.knownDevices[deviceName] || null;

            if (props === null) {
                return;
            }

            // information
            sensorAbout.description = deviceType !== kDeviceTypeInternal ? deviceName : controller.integratedProviderName

            // alert styles
            var alertStylesDescString = "";

            if (props.locationAlertsVisual !== undefined && props.locationAlertsVisual) {
                alertStylesDescString += "%1".arg(sensorAlerts.kBanner);
            }

            if (props.locationAlertsSpeech !== undefined && props.locationAlertsSpeech) {
                alertStylesDescString += alertStylesDescString > "" ? ", %1".arg(sensorAlerts.kVoice) : "%1".arg(sensorAlerts.kVoice);
            }

            if (props.locationAlertsVibrate !== undefined && props.locationAlertsVibrate) {
                alertStylesDescString += alertStylesDescString > "" ? ", %1".arg(sensorAlerts.kVibrate) : "%1".arg(sensorAlerts.kVibrate);
            }

            if (alertStylesDescString === "") {
                alertStylesDescString = "%1".arg(sensorAlerts.kNone);
            }

            sensorAlerts.description = alertStylesDescString;

            // altitude type
            if (props.altitudeType !== undefined) {
                sensorAltitude.description = props.altitudeType === gnssSettings.kAltitudeTypeMSL
                        ? sensorAltitude.altitudeTypeMSLLabel
                        : props.altitudeType === gnssSettings.kAltitudeTypeHAE
                          ? sensorAltitude.altitudeTypeHAELabel
                          : "";
            }

            // antenna height
            if (props.antennaHeight !== undefined) {
                sensorAntennaHeight.description = isFinite(props.antennaHeight)
                        ? toLocaleLengthString(props.antennaHeight, locale)
                        : toLocaleLengthString(0, locale);
            }
        }
    }

    //--------------------------------------------------------------------------

}
