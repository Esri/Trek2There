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

import ArcGIS.AppFramework 1.0
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

    readonly property double scaleFactor: AppFramework.displayScaleFactor
    readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"
    property bool showDevices
    property bool initialized

    property int sideMargin: 15 * scaleFactor

    property string backgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
    property string secondaryBackgroundColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
    property string foregroundColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
    property string secondaryForegroundColor: buttonTextColor

    property string imageLocation: "../images/"

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal disconnect()

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        showDevices = !useTCPConnection;
        initialized = true;

        if (showDevices && (discoveryAgent.running || !discoveryAgent.devices || discoveryAgent.devices.count == 0)) {
            discoverySwitch.checked = true;
        } else {
            discoverySwitch.checked = false;
        }

        if (tcpRadioButton.checked) {
            connectionType = sources.eConnectionType.network;
        } else {
            connectionType = sources.eConnectionType.external;
        }
    }

    StackView.onDeactivating: {
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

            //--------------------------------------------------------------------------

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
                        Layout.preferredHeight: 50 * scaleFactor

                        color: secondaryBackgroundColor
                        Accessible.role: Accessible.Pane

                        Text {
                            id: connectionTitle

                            anchors.fill: parent
                            anchors.leftMargin: sideMargin
                            anchors.bottomMargin: 5 * scaleFactor

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
                                Layout.leftMargin: sideMargin

                                text: "TCP/UDP Connection"
                                checked: !showDevices

                                onCheckedChanged: {
                                    if (initialized && checked) {
                                        connectionType = sources.eConnectionType.network;
                                    }
                                }
                            }

                            //--------------------------------------------------------------------------

                            Label {
                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 1
                                Layout.column: 0
                                Layout.leftMargin: sideMargin

                                text: "Hostname"
                                color: foregroundColor
                            }

                            TextField {
                                id: hostnameTF

                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 1
                                Layout.column: 1
                                Layout.fillWidth: true

                                text: app.hostname
                                placeholderText: "Hostname"
                            }

                            //--------------------------------------------------------------------------

                            Label {
                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 2
                                Layout.column: 0
                                Layout.leftMargin: sideMargin

                                text: "Port"
                                color: foregroundColor
                            }

                            TextField {
                                id: portTF

                                enabled: !showDevices
                                visible: !showDevices

                                Layout.row: 2
                                Layout.column: 1
                                Layout.fillWidth: true

                                text: app.port;
                                placeholderText: "Port"
                            }

                            Button {
                                id: connectBtn

                                enabled: !showDevices && hostname && port
                                visible: !showDevices

                                Layout.row: 2
                                Layout.column: 2
                                Layout.rightMargin: sideMargin

                                text: qsTr("Connect")

                                onClicked: networkHostSelected(hostname, port)
                            }

                            //--------------------------------------------------------------------------

                            SettingsRadioButton {
                                id: deviceRadioButton

                                Layout.row: 3
                                Layout.column: 0
                                Layout.columnSpan: 3
                                Layout.leftMargin: sideMargin

                                text: "External device"
                                checked: showDevices

                                onCheckedChanged: {
                                    if (initialized) {
                                        disconnect();
                                        showDevices = checked;
                                        discoverySwitch.checked = discoveryAgent.devices.count == 0;

                                        if (checked) {
                                            connectionType = sources.eConnectionType.external;
                                            if (currentDevice && currentDevice.name === storedDevice) {
                                                sources.deviceSelected(currentDevice);
                                                discoverySwitch.checked = false;
                                            }
                                        }
                                    }
                                }
                            }

                            //--------------------------------------------------------------------------

                            SettingsSwitch {
                                id: discoverySwitch

                                enabled: showDevices && (bluetoothCheckBox.checked || usbCheckBox.checked)
                                visible: showDevices

                                Layout.row: 4
                                Layout.column: 0
                                Layout.fillWidth: true
                                Layout.leftMargin: sideMargin

                                text: "Discovery %1".arg(checked ? "on" : "off")

                                onCheckedChanged: {
                                    if (initialized) {
                                        if (checked) {
                                            disconnect();
                                            if (!discoveryAgent.running) {
                                                discoveryAgent.start();
                                            }
                                        } else {
                                            discoveryAgent.stop();
                                        }
                                    }
                                }

                                Connections {
                                    target: discoveryAgent

                                    onRunningChanged: discoverySwitch.checked = discoveryAgent.running
                                }
                            }

                            SettingsCheckBox {
                                id: bluetoothCheckBox

                                enabled: showDevices && !discoverySwitch.checked
                                visible: showDevices && !bluetoothOnly

                                Layout.row: 4
                                Layout.column: 1

                                text: "Bluetooth"

                                checked: discoverBluetooth ? true : false
                                onCheckedChanged: {
                                    if (initialized) {
                                        discoverBluetooth = checked ? true : false
                                    }
                                }
                            }

                            SettingsCheckBox {
                                id: usbCheckBox

                                enabled: showDevices && !discoverySwitch.checked
                                visible: showDevices && !bluetoothOnly

                                Layout.row: 4
                                Layout.column: 2
                                Layout.rightMargin: sideMargin

                                text: "USB/COM"

                                checked: discoverSerialPort ? true : false
                                onCheckedChanged: {
                                    if (initialized) {
                                        discoverSerialPort = checked ? true : false
                                    }
                                }
                            }
                        }
                    }

                    //--------------------------------------------------------------------------

                    Rectangle {
                        id: deviceTitleRowRect

                        anchors.top: connectionTypeGridRect.bottom
                        Layout.fillWidth: true;
                        Layout.preferredHeight: 50 * scaleFactor

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
                                Layout.bottomMargin: 5 * scaleFactor

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
                                Layout.preferredWidth: 30 * scaleFactor
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.rightMargin: sideMargin
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

                        enabled: showDevices
                        visible: showDevices

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

                    height: 45 * scaleFactor
                    Layout.fillWidth: true

                    Image {
                        id: leftImage

                        width: 25 * scaleFactor
                        height: rowLayout.height
                        Layout.preferredWidth: leftImage.width
                        Layout.preferredHeight: leftImage.height
                        anchors.left: parent.left
                        anchors.leftMargin: 10 * scaleFactor

                        source: imageLocation + "deviceType-%1.png".arg(deviceType)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: leftImage
                        source: leftImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? secondaryForegroundColor : foregroundColor
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: currentDevice && (currentDevice.name === name) ? isConnecting ? name + qsTr(" (Connecting...)") : isConnected ? name + qsTr(" (Connected)") : name : name
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? secondaryForegroundColor : foregroundColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                    }

                    Image {
                        id: rightImage

                        width: 25 * scaleFactor
                        height: rowLayout.height
                        Layout.preferredWidth: rightImage.width
                        Layout.preferredHeight: rightImage.height
                        anchors.right: parent.right
                        anchors.rightMargin: 10 * scaleFactor

                        source: imageLocation + "right.png"
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

                    height: 1 * scaleFactor
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

        height: 48 * scaleFactor
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
