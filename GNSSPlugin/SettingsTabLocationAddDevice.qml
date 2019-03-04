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
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "./controls"

SettingsTab {
    id: sensorAddDeviceTab

    title: qsTr("Add Provider")

    //--------------------------------------------------------------------------

    SettingsTabContainer {
        id: settingsTabContainer
    }

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        // Internal properties -------------------------------------------------

        readonly property PositioningSourcesController controller: locationSettingsTab.controller
        readonly property DeviceDiscoveryAgent discoveryAgent: controller.discoveryAgent

        readonly property alias hostname: hostnameTextField.text
        readonly property alias port: portTextField.text

        readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"
        readonly property bool selectionValid: bluetoothCheckBox.checked || bluetoothLECheckBox.checked || usbCheckBox.checked

        property bool addExternalDevice: true
        property bool addNetworkDevice: !addExternalDevice

        property bool initialized

        // ---------------------------------------------------------------------

        Component.onCompleted: {
            _item.initialized = true;

            // omit previously stored device from discovered devices list
            // cachedReceiversListModel is available via parent view

            discoveryAgent.deviceFilter = function(device) {
                for (var i = 0; i < cachedReceiversListModel.count; i++) {
                    var cachedReceiver = cachedReceiversListModel.get(i);
                    if (device && cachedReceiver && device.name === cachedReceiver.name) {
                        return false;
                    }
                }
                return discoveryAgent.filter(device);
            }

            if (addExternalDevice && selectionValid) {
                discoverySwitch.checked = true;
            }
        }

        // ---------------------------------------------------------------------

        Component.onDestruction: {
            // Clear the model so old devices are not visible if view is re-loaded.
            discoveryAgent.devices.clear();

            // reset standard filter
            discoveryAgent.deviceFilter = function(device) { return discoveryAgent.filter(device); }

            // stop the discoveryAgent
            discoveryAgent.stop();
        }

        // ---------------------------------------------------------------------

        ColumnLayout {
            anchors {
                fill: parent
                margins: 10 * AppFramework.displayScaleFactor
            }

            spacing: 10 * AppFramework.displayScaleFactor

            Accessible.role: Accessible.Pane

            // -----------------------------------------------------------------

            GroupColumnLayout {
                Layout.fillWidth: true

                title: qsTr("Location provider")

                AppRadioButton {
                    id: showDevicesRadioButton
                    Layout.fillWidth: true

                    text: qsTr("External receiver")
                    checked: true

                    onCheckedChanged: {
                        if (_item.initialized) {
                            if (checked) {
                                _item.addExternalDevice = true;
                                discoverySwitch.checked = true;
                            }
                        }
                    }
                }

                AppRadioButton {
                    id: networkConnectionRadioButton
                    Layout.fillWidth: true

                    text: qsTr("Network connection")

                    onCheckedChanged: {
                        if (_item.initialized) {
                            if (checked) {
                                _item.addExternalDevice = false;
                                discoverySwitch.checked = false;
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------

            GroupColumnLayout {
                Layout.fillWidth: true

                title: qsTr("Connection parameters")
                visible: _item.addNetworkDevice

                GridLayout {
                    Layout.fillWidth: true

                    columns: 2
                    rows: 2

                    // ---------------------------------------------------------

                    AppText {
                        Layout.row: 0
                        Layout.column: 0

                        color: foregroundColor
                        text: qsTr("Hostname")
                    }

                    AppTextField {
                        id: hostnameTextField

                        Layout.row: 0
                        Layout.column: 1
                        Layout.fillWidth: true

                        text: gnssSettings.hostname
                        placeholderText: qsTr("Hostname")
                        textColor: foregroundColor
                    }

                    AppText {
                        Layout.row: 1
                        Layout.column: 0

                        text: qsTr("Port")
                        color: foregroundColor
                    }

                    AppTextField {
                        id: portTextField

                        Layout.row: 1
                        Layout.column: 1
                        Layout.fillWidth: true

                        text: gnssSettings.port
                        placeholderText: qsTr("Port")
                        textColor: foregroundColor
                    }
                }

                StyledButton {
                    enabled: _item.hostname > "" && _item.port > 0

                    Layout.fillWidth: true
                    fontFamily: locationSettingsTab.fontFamily

                    text: qsTr("Add")

                    onClicked: {
                        var networkName = gnssSettings.createNetworkSettings(_item.hostname, _item.port);
                        controller.networkHostSelected(_item.hostname, _item.port);
                        _item.showReceiverSettingsPage(networkName);
                    }
                }
            }

            // -----------------------------------------------------------------

            GroupColumnLayout {
                id: devicesGroup

                Layout.fillWidth: true
                Layout.fillHeight: true

                title: qsTr("External receivers")
                visible: _item.addExternalDevice

                layout.height: devicesGroup.height - layout.anchors.margins * 2 - layout.parent.anchors.margins
                implicitHeight: 0

                AppBusyIndicator {
                    parent: devicesGroup

                    anchors {
                        right: parent.right
                        rightMargin: 10 * AppFramework.displayScaleFactor
                        top: parent.top
                        topMargin: 10 * AppFramework.displayScaleFactor
                    }

                    implicitSize: 8

                    running: discoverySwitch.checked
                }

                Flow {
                    Layout.fillWidth: true

                    AppSwitch {
                        id: discoverySwitch

                        property bool updating

                        enabled: selectionValid

                        text: qsTr("Discover")

                        onCheckedChanged: {
                            if (_item.initialized && !updating) {
                                if (checked) {
                                    devicesListView.model.clear()
                                    controller.startDiscoveryAgent();
                                } else {
                                    controller.stopDiscoveryAgent();
                                }
                            }
                        }

                        Connections {
                            target: _item.discoveryAgent

                            onRunningChanged: {
                                discoverySwitch.updating = true;
                                discoverySwitch.checked = _item.discoveryAgent.running;
                                discoverySwitch.updating = false;
                            }
                        }
                    }

                    AppCheckBox {
                        id: bluetoothCheckBox

                        enabled: !discoverySwitch.checked
                        visible: true

                        text: qsTr("Bluetooth")

                        checked: gnssSettings.discoverBluetooth ? true : false
                        onCheckedChanged: {
                            if (_item.initialized) {
                                gnssSettings.discoverBluetooth = checked ? true : false
                            }
                        }
                    }

                    AppCheckBox {
                        id: bluetoothLECheckBox

                        enabled: !discoverySwitch.checked
                        visible: true

                        text: qsTr("BluetoothLE")

                        checked: gnssSettings.discoverBluetoothLE ? true : false
                        onCheckedChanged: {
                            if (_item.initialized) {
                                gnssSettings.discoverBluetoothLE = checked ? true : false
                            }
                        }
                    }

                    AppCheckBox {
                        id: usbCheckBox

                        enabled: !discoverySwitch.checked
                        visible: !_item.bluetoothOnly

                        text: qsTr("USB/COM")

                        checked: gnssSettings.discoverSerialPort ? true : false
                        onCheckedChanged: {
                            if (_item.initialized) {
                                gnssSettings.discoverSerialPort = checked ? true : false
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true

                    height: 2 * AppFramework.displayScaleFactor
                    color: dividerColor
                }

                ListView {
                    id: devicesListView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true
                    spacing: 5 * AppFramework.displayScaleFactor

                    model: _item.discoveryAgent.devices
                    delegate: deviceDelegate
                }
            }

            // -----------------------------------------------------------------

            Item {
                visible: _item.addNetworkDevice

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        // ---------------------------------------------------------------------

        Component {
            id: deviceDelegate

            Rectangle {
                id: delegateRect

                height: deviceLayout.height
                width: devicesListView.width
                radius: 4 * AppFramework.displayScaleFactor

                color: "transparent"
                opacity: parent.enabled ? 1.0 : 0.7

                ColumnLayout {
                    id: deviceLayout

                    width: parent.width
                    spacing: 2 * AppFramework.displayScaleFactor

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10 * AppFramework.displayScaleFactor

                        StyledImage {
                            width: 25 * AppFramework.displayScaleFactor
                            height: width

                            Layout.preferredWidth: width
                            Layout.preferredHeight: height
                            Layout.alignment: Qt.AlignLeft

                            source: "./images/deviceType-%1.png".arg(deviceType)
                            color: foregroundColor
                        }

                        AppText {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            text: name
                            color: foregroundColor
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            verticalAlignment: Text.AlignVCenter

                            pointSize: 14
                            fontFamily: locationSettingsTab.fontFamily
                            bold: false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        height: 1 * AppFramework.displayScaleFactor
                        color: dividerColor
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        var device = _item.discoveryAgent.devices.get(index);
                        var deviceName = gnssSettings.createExternalReceiverSettings(name, device.toJson());
                        controller.deviceSelected(device);
                        _item.showReceiverSettingsPage(deviceName);
                    }
                }
            }
        }

        // ---------------------------------------------------------------------

        function showReceiverSettingsPage(name) {
            // gnssSettings.createExternalReceiverSettings() creates a new tab in
            // the locationSettingsTab page. Go and get it.
            var item = null;
            var model = locationSettingsTab.currentListTabView.contentData;
            for (var i=0; i<model.length; i++) {
                if (model[i].title === name) {
                    item = model[i];
                    break;
                }
            }

            if (item) {
                // go to the detailed settings of the new device
                stackView.replace(settingsTabContainer, {
                                      settingsTab: item,
                                      title: item.title,
                                      settingsComponent: item.contentComponent
                                  });
            } else {
                // fallback
                stackView.pop();
            }
        }

        // ---------------------------------------------------------------------
    }

    //--------------------------------------------------------------------------
}
