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
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework.Devices 1.0

import "../controls"

Item {
    id: devicePage

    property DeviceDiscoveryAgent discoveryAgent
    property Device currentDevice
    property bool isConnecting
    property bool isConnected

    property string hostname: hostnameTF.text
    property string port: portTF.text

    readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"
    property bool showDevices
    property bool initialized

    property string backgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
    property string secondaryBackgroundColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
    property string foregroundColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
    property string secondaryForegroundColor: buttonTextColor

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal disconnect()

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        showDevices = !useTCPConnection;
        initialized = true;

        if (showDevices && (!discoveryAgent.devices || discoveryAgent.devices.count == 0)) {
            discoverySwitch.checked = true;
        } else {
            discoverySwitch.checked = false;
        }
    }

    StackView.onDeactivating: {
        discoveryAgent.stop();
        initialized = false;
    }

    //--------------------------------------------------------------------------

    onIsConnectedChanged: {
        if (initialized && isConnected) {
            mainStackView.pop();
        }
    }

    //--------------------------------------------------------------------------

    onNetworkHostSelected: {
        app.settings.setValue("hostname", hostname);
        app.settings.setValue("port", port);

        sources.networkHostSelected(hostname, port);
    }

    //--------------------------------------------------------------------------

    onDeviceSelected: {
        app.settings.setValue("device", device.name);

        sources.deviceSelected(device);
    }

    //--------------------------------------------------------------------------

    onDisconnect: {
        sources.disconnect();
    }

    //--------------------------------------------------------------------------

    ButtonGroup {
        id: buttonGroup

        buttons: [tcpRadioButton.radioButton, deviceRadioButton.radioButton]
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        Accessible.role: Accessible.Pane

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            SettingsHeader {
                text: qsTr("Search external receiver")
            }

            //------------------------------------------------------------------

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: contentItem.children[0].childrenRect.height
                contentWidth: parent.width
                Accessible.role: Accessible.Pane

                interactive: true
                flickableDirection: Flickable.VerticalFlick
                clip: true

                ColumnLayout {
                    anchors.fill: parent

                    //--------------------------------------------------------------------------

                    Rectangle {
                        id: connectionTitleRect

                        anchors.top: parent.top
                        Layout.fillWidth: true
                        Layout.preferredHeight: sf(50)

                        color: secondaryBackgroundColor
                        Accessible.role: Accessible.Pane

                        Text {
                            id: connectionTitle

                            anchors.fill: parent
                            anchors.leftMargin: sideMargin
                            anchors.bottomMargin: sf(5)

                            text: qsTr("CONNECTION SETTINGS")
                            verticalAlignment: Text.AlignBottom
                            color: foregroundColor

                            Accessible.role: Accessible.Heading
                            Accessible.name: text
                            Accessible.description: qsTr("Choose the connection type")
                        }
                    }

                    //--------------------------------------------------------------------------

                    Rectangle {
                        id: connectionTypeGridRect

                        anchors.top: connectionTitleRect.bottom
                        Layout.fillWidth: true
                        Layout.preferredHeight: connectionTypeGrid.height

                        color: backgroundColor
                        Accessible.role: Accessible.Pane

                        GridLayout {
                            id: connectionTypeGrid

                            columns: 3
                            rows: 5

                            anchors.left: parent.left
                            anchors.right: parent.right

                            //--------------------------------------------------------------------------

                            SettingsRadioButton {
                                id: tcpRadioButton

                                Layout.row: 0
                                Layout.column: 0
                                Layout.columnSpan: 3

                                text: "TCP/UDP Connection"
                                checked: !showDevices
                            }

                            //--------------------------------------------------------------------------

                            Label {
                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 1
                                Layout.column: 0
                                Layout.leftMargin: sideMargin

                                text: "Hostname"
                                font.pixelSize: baseFontSize
                                color: foregroundColor
                            }

                            TextField {
                                id: hostnameTF

                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 1
                                Layout.column: 1
                                Layout.fillWidth: true

                                text: app.settings.value("hostname", "");
                                placeholderText: "Hostname"
                                font.pixelSize: baseFontSize
                            }

                            //--------------------------------------------------------------------------

                            Label {
                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 2
                                Layout.column: 0
                                Layout.leftMargin: sideMargin

                                text: "Port"
                                font.pixelSize: baseFontSize
                                color: foregroundColor
                            }

                            TextField {
                                id: portTF

                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 2
                                Layout.column: 1
                                Layout.fillWidth: true

                                text: app.settings.value("port", "").toString();
                                placeholderText: "Port"
                                font.pixelSize: baseFontSize
                            }

                            Button {
                                id: connectBtn

                                enabled: !showDevices && hostname && port
                                visible: !showDevices

                                Layout.row: 2
                                Layout.column: 2
                                Layout.rightMargin: sideMargin

                                text: qsTr("Connect")
                                font.pixelSize: baseFontSize

                                onClicked: networkHostSelected(hostname, port)
                            }

                            //--------------------------------------------------------------------------

                            SettingsRadioButton {
                                id: deviceRadioButton

                                Layout.row: 3
                                Layout.column: 0
                                Layout.columnSpan: 3

                                text: "External device"
                                checked: showDevices

                                onCheckedChanged: {
                                    if (initialized) {
                                        disconnect();
                                        showDevices = checked;

                                        if (checked && (!discoveryAgent.devices || discoveryAgent.devices.count == 0)) {
                                            discoverySwitch.checked = true;
                                        } else {
                                            discoverySwitch.checked = false;
                                        }
                                    }
                                }
                            }

                            //--------------------------------------------------------------------------

                            Switch {
                                id: discoverySwitch

                                enabled: showDevices && (bluetoothCheckBox.checked || usbCheckBox.checked)
                                visible: showDevices

                                Layout.row: 4
                                Layout.column: 0
                                Layout.fillWidth: true
                                Layout.leftMargin: sideMargin

                                text: "Discovery %1".arg(checked ? "on" : "off")
                                font.pixelSize: baseFontSize

                                onCheckedChanged: {
                                    if (initialized) {
                                        if (checked) {
                                            disconnect();
                                            discoveryAgent.start();
                                        } else {
                                            discoveryAgent.stop();
                                        }
                                    }
                                }

                                Connections {
                                    target: discoveryAgent

                                    onRunningChanged: {
                                        if (!discoveryAgent.running) {
                                            discoverySwitch.checked = false;
                                        }
                                    }
                                }
                            }

                            CheckBox {
                                id: bluetoothCheckBox

                                enabled: showDevices && !discoverySwitch.checked
                                visible: showDevices && !bluetoothOnly

                                Layout.row: 4
                                Layout.column: 1

                                text: "Bluetooth"
                                font.pixelSize: baseFontSize

                                checked: discoveryAgent.detectBluetooth

                                onCheckedChanged: discoveryAgent.detectBluetooth = checked ? true : false
                            }

                            CheckBox {
                                id: usbCheckBox

                                enabled: showDevices && !discoverySwitch.checked
                                visible: showDevices && !bluetoothOnly

                                Layout.row: 4
                                Layout.column: 2

                                text: "USB/COM"
                                font.pixelSize: baseFontSize

                                checked: discoveryAgent.detectSerialPort

                                onCheckedChanged: discoveryAgent.detectSerialPort = checked ? true : false
                            }
                        }
                    }

                    //--------------------------------------------------------------------------

                    Rectangle {
                        id: deviceTitleRowRect

                        anchors.top: connectionTypeGridRect.bottom
                        Layout.fillWidth: true;
                        Layout.preferredHeight: sf(50)

                        color: secondaryBackgroundColor
                        Accessible.role: Accessible.Pane

                        RowLayout {
                            id: deviceTitleRow

                            anchors.fill: parent
                            spacing: 0

                            Text {
                                id: deviceTitle

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.leftMargin: sideMargin
                                Layout.bottomMargin: sf(5)

                                text: qsTr("SELECT A DEVICE")
                                verticalAlignment: Text.AlignBottom
                                color: foregroundColor

                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Choose an external GPS device")
                            }

                            Rectangle {
                                id: discoveryIndicatorRect

                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(30)
                                anchors.bottom: parent.bottom
                                color: secondaryBackgroundColor

                                BusyIndicator {
                                    id: discoveryIndicator

                                    anchors.fill: parent

                                    running: discoveryAgent.running
                                }

                                ColorOverlay {
                                    anchors.fill: discoveryIndicator
                                    source: discoveryIndicator
                                    color: secondaryForegroundColor
                                }
                            }
                        }
                    }

                    //--------------------------------------------------------------------------

                    Rectangle {
                        id: deviceListRect

                        anchors.top: deviceTitleRowRect.bottom
                        Layout.fillWidth: true;
                        Layout.preferredHeight: deviceListColumn.height

                        color: backgroundColor
                        Accessible.role: Accessible.Pane

                        ColumnLayout {
                            id: deviceListColumn

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            spacing: 0

                            Repeater {
                                enabled: showDevices
                                visible: showDevices

                                clip: true

                                model: discoveryAgent.devices
                                delegate: deviceDelegate
                            }
                        }
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: deviceDelegate

        Rectangle {
            id: delegateRect

            Layout.preferredHeight: deviceLayout.height
            Layout.preferredWidth: deviceListRect.width

            color: backgroundColor
            opacity: parent.enabled ? 1.0 : 0.7

            ColumnLayout {
                id: deviceLayout

                height: rowLayout.height + separator.height
                width: delegateRect.width
                spacing: 0

                RowLayout {
                    id: rowLayout

                    height: sf(35)
                    Layout.fillWidth: true

                    Image {
                        id: leftImage

                        width: sf(25)
                        height: rowLayout.height
                        Layout.preferredWidth: leftImage.width
                        Layout.preferredHeight: leftImage.height
                        anchors.left: parent.left
                        anchors.leftMargin: sf(10)

                        source:"../images/deviceType-%1.png".arg(deviceType)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: leftImage
                        source: leftImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? secondaryForegroundColor : foregroundColor
                    }

                    Text {
                        height: rowLayout.height
                        Layout.fillWidth: true

                        text: currentDevice && (currentDevice.name === name) ? isConnecting ? name + qsTr(" (Connecting...)") : isConnected ? name + qsTr(" (Connected)") : name : name
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? secondaryForegroundColor : foregroundColor
                        font.pixelSize: baseFontSize * 0.9
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Image {
                        id: rightImage

                        width: sf(25)
                        height: rowLayout.height
                        Layout.preferredWidth: rightImage.width
                        Layout.preferredHeight: rightImage.height
                        anchors.right: parent.right
                        anchors.rightMargin: sf(10)

                        source:"../images/right.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: rightImage
                        source: rightImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? secondaryForegroundColor : foregroundColor
                    }
                }

                Rectangle {
                    id: separator

                    height: sf(1)
                    Layout.fillWidth: true
                    color: secondaryBackgroundColor
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (!isConnecting && !isConnected || currentDevice && currentDevice.name !== name) {
                        deviceSelected(discoveryAgent.devices.get(index));
                    } else {
                        app.settings.remove("device");
                        disconnect();
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    BusyIndicator {
        id: connectingIndicator

        running: isConnecting
        visible: running

        height: sf(48)
        width: height
        anchors.centerIn: parent
    }

    ColorOverlay {
        anchors.fill: connectingIndicator
        source: connectingIndicator
        color: secondaryForegroundColor
    }

    //--------------------------------------------------------------------------
}
