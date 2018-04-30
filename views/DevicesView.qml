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

    property bool initialized
    property bool showDevices
    readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"

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
        if (isConnected) {
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
        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
        Accessible.role: Accessible.Pane

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Accessible.role: Accessible.Pane

            SettingsHeader {
                text: qsTr("Search external receiver")
            }

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
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
                        spacing: 0

                        //--------------------------------------------------------------------------

                        Rectangle {
                            id: discoveryTitleRect

                            anchors.top: parent.top
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true

                            color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                            Accessible.role: Accessible.Pane

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.bottomMargin: sf(5)
                                text: qsTr("DISCOVERY SETTINGS")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                                Accessible.description: qsTr("Choose the connection type")
                            }
                        }

                        //--------------------------------------------------------------------------

                        Rectangle {
                            id: deviceSelectionGridRect

                            anchors.top: discoveryTitleRect.bottom
                            Layout.preferredHeight: deviceSelectionGrid.height
                            Layout.fillWidth: true

                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            GridLayout {
                                id: deviceSelectionGrid

                                columns: 3
                                rows: 5

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.rightMargin: sideMargin

                                //--------------------------------------------------------------------------

                                SettingsRadioButton {
                                    id: tcpRadioButton

                                    Layout.row: 0
                                    Layout.column: 0
                                    Layout.columnSpan: 3
                                    Layout.fillWidth: true

                                    text: "TCP Connection"
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
                                    Layout.fillWidth: true

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

                                    checked: true

                                    onCheckedChanged: discoveryAgent.detectBluetooth = checked
                                }

                                CheckBox {
                                    id: usbCheckBox

                                    enabled: showDevices && !discoverySwitch.checked
                                    visible: showDevices && !bluetoothOnly

                                    Layout.row: 4
                                    Layout.column: 2

                                    text: "USB"
                                    font.pixelSize: baseFontSize

                                    checked: false

                                    onCheckedChanged: discoveryAgent.detectSerialPort = checked
                                }
                            }
                        }

                        //--------------------------------------------------------------------------

                        RowLayout {
                            anchors.top: deviceSelectionGridRect.bottom
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            Layout.bottomMargin: sf(5)
                            spacing: 0

                            Rectangle {
                                id: deviceTitleRect

                                Layout.preferredHeight: sf(50)
                                Layout.fillWidth: true

                                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                Accessible.role: Accessible.Pane

                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: sideMargin
                                    anchors.bottomMargin: sf(5)
                                    text: qsTr("SELECT A DEVICE")
                                    verticalAlignment: Text.AlignBottom
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    Accessible.role: Accessible.Heading
                                    Accessible.name: text
                                }
                            }

                            Rectangle {
                                Layout.preferredHeight: sf(50)
                                Layout.preferredWidth: sf(25)
                                anchors.bottom: parent.bottom
                                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

                                BusyIndicator {
                                    id: discoveryIndicator

                                    anchors.fill: parent

                                    running: discoveryAgent.running
                                }

                                ColorOverlay {
                                    anchors.fill: discoveryIndicator
                                    source: discoveryIndicator
                                    color: buttonTextColor
                                }
                            }
                        }

                        Rectangle {
                            property real contentHeight: deviceListView.count * deviceListView.contentHeight

                            Layout.fillWidth: true
                            Layout.minimumHeight: sf(184)
                            height: contentHeight > Layout.minimumHeight ? contentHeight :  Layout.minimumHeight
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            ListView {
                                id: deviceListView

                                enabled: showDevices
                                visible: showDevices

                                anchors.fill: parent

                                spacing: 0
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

            width: ListView.view.width
            height: deviceLayout.height

            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
            opacity: parent.enabled ? 1.0 : 0.7

            ColumnLayout {
                id: deviceLayout

                width: parent.width
                spacing: sf(20)

                RowLayout {
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        width: sf(12)
                    }

                    Image {
                        id: deviceImage

                        width: sf(25)
                        height: width
                        Layout.preferredWidth: sf(25)
                        Layout.preferredHeight: Layout.preferredWidth

                        source:"../images/deviceType-%1.png".arg(deviceType)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: deviceImage
                        source: deviceImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? buttonTextColor : !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    }

                    Item {
                        width: sf(2)
                    }

                    Text {
                        Layout.fillWidth: true

                        text: currentDevice && (currentDevice.name === name) ? isConnecting ? name + qsTr(" (Connecting...)") : isConnected ? name + qsTr(" (Connected)") : name : name
                        font.pixelSize: baseFontSize * 0.9
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? buttonTextColor : !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    }

                    Image {
                        id:rightImage

                        anchors.right: parent.right
                        width: sf(25)
                        height: width
                        Layout.preferredWidth: sf(25)
                        Layout.preferredHeight: Layout.preferredWidth

                        source:"../images/right.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: rightImage
                        source: rightImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? buttonTextColor : !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: sf(1)
                    color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (!isConnecting && !isConnected || currentDevice && currentDevice.name !== name) {
                        deviceListView.currentIndex = index;
                        deviceSelected(discoveryAgent.devices.get(index));
                    } else {
                        app.settings.remove("device");

                        deviceListView.currentIndex = -1;
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
        color: buttonTextColor
    }

    //--------------------------------------------------------------------------
}
