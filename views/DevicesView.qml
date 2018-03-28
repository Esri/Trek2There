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
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Speech 1.0

import "../controls"

Item {
    id: devicePage

    property string hostname: hostnameTF.text
    property string port: portTF.text

    property bool showDevices: true
    property bool isConnecting
    property bool isConnected

    readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"

    property color primaryColor: "#8f499c"

    signal deviceSelected(string name, Device device)
    signal networkHostSelected(string hostname, int port)
    signal disconnect()

    //--------------------------------------------------------------------------

    StackView.onDeactivated: {
        discoveryAgent.stop();
    }

    //--------------------------------------------------------------------------

    onDeviceSelected: {
        console.log("Connecting to device:", name, device, device.name, "type:", device.deviceType, "address:", device.address);

        disconnect();

        useTCPConnection = false;
        currentDevice = device;
        nmeaSource.source = currentDevice;

        // allow for a short delay before connecting so that the listview has time to update
        deviceConnectionTimer.interval = 1000;
        deviceConnectionTimer.start();
    }

    //--------------------------------------------------------------------------

    onNetworkHostSelected: {
        console.log("Connecting to remote host:", hostname, "port:", port);

        disconnect();

        app.settings.setValue("hostname", hostname);
        app.settings.setValue("port", port);

        useTCPConnection = true;
        nmeaSource.source = tcpSocket;
        tcpSocket.connectToHost(hostname, port);
    }

    //--------------------------------------------------------------------------

    onDisconnect: {
        if (tcpSocket.valid && tcpSocket.state === AbstractSocket.StateConnected) {
            console.log("Disconnecting from remote host:", tcpSocket.remoteName);
            tcpSocket.disconnectFromHost();
        }

        if (currentDevice && currentDevice.connected) {
            console.log("Disconnecting device:", currentDevice.name);
            currentDevice.connected = false;
            currentDevice = null;
        }

        isConnected = false;
        isConnecting = false;
    }

    //--------------------------------------------------------------------------

    onIsConnectedChanged: {
        // XXX stub
    }

    //--------------------------------------------------------------------------

    ButtonGroup {
        id: buttonGroup

        buttons: [tcpRadioButton, deviceRadioButton]
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
                        enabled: !isConnecting

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

                                columns: 4
                                rows: 5

                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin

                                //--------------------------------------------------------------------------

                                RadioButton {
                                    id: tcpRadioButton

                                    Layout.row: 0
                                    Layout.column: 0
                                    Layout.columnSpan: 4
                                    Layout.fillWidth: true

                                    text: "TCP Connection"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor

                                    checked: false //useTCPConnection // XXX crash due to circular binding
                                }

                                //--------------------------------------------------------------------------

                                Label {
                                    enabled: !showDevices
                                    visible: !showDevices

                                    Layout.row: 1
                                    Layout.column: 0

                                    text: "Hostname"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor
                                }

                                TextField {
                                    id: hostnameTF

                                    enabled: !showDevices
                                    visible: !showDevices

                                    Layout.row: 1
                                    Layout.column: 1
                                    Layout.columnSpan: 2
                                    Layout.fillWidth: true

                                    text: app.settings.value("hostname", "");
                                    placeholderText: "Hostname"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor
                                }

                                //--------------------------------------------------------------------------

                                Label {
                                    enabled: !showDevices
                                    visible: !showDevices

                                    Layout.row: 2
                                    Layout.column: 0

                                    text: "Port"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor
                                }

                                TextField {
                                    id: portTF

                                    enabled: !showDevices
                                    visible: !showDevices

                                    Layout.row: 2
                                    Layout.column: 1
                                    Layout.columnSpan: 2
                                    Layout.fillWidth: true

                                    text: app.settings.value("port", "").toString();
                                    placeholderText: "Port"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor
                                }

                                Button {
                                    id: connectBtn

                                    enabled: !showDevices && hostname && port
                                    visible: !showDevices

                                    Layout.row: 2
                                    Layout.column: 3
                                    Layout.alignment: Qt.AlignHCenter

                                    text: qsTr("Connect")
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor

                                    onClicked: networkHostSelected(hostname, port)
                                }

                                //--------------------------------------------------------------------------

                                RadioButton {
                                    id: deviceRadioButton

                                    Layout.row: 3
                                    Layout.column: 0
                                    Layout.columnSpan: 4
                                    Layout.fillWidth: true

                                    text: "External device"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor

                                    checked: true

                                    onCheckedChanged: {
                                        showDevices = checked
                                        disconnect();
                                        if (checked && discoverySwitch.checked) {
                                            discoveryAgent.start();
                                        } else {
                                            discoveryAgent.stop();
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
                                    Layout.columnSpan: 2
                                    Layout.fillWidth: true

                                    text: "Discovery %1".arg(checked ? "active" : "off")
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor

                                    Component.onCompleted: {
                                        checked = true;
                                    }

                                    onCheckedChanged: {
                                        if (checked) {
                                            discoveryAgent.start();
                                        } else {
                                            discoveryAgent.stop();
                                        }
                                    }
                                }

                                CheckBox {
                                    id: bluetoothCheckBox

                                    enabled: showDevices && !discoverySwitch.checked
                                    visible: showDevices && !bluetoothOnly

                                    Layout.row: 4
                                    Layout.column: 2

                                    text: "Bluetooth"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor

                                    checked: true
                                }

                                CheckBox {
                                    id: usbCheckBox

                                    enabled: showDevices && !discoverySwitch.checked
                                    visible: showDevices && !bluetoothOnly

                                    Layout.row: 4
                                    Layout.column: 3

                                    text: "USB"
                                    font.pixelSize: baseFontSize
                                    //Material.accent: primaryColor

                                    checked: false
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
                                    anchors.fill: parent

                                    running: discoveryAgent.running

                                    ColorOverlay {
                                        anchors.fill: parent
                                        source: parent
                                        color: buttonTextColor
                                    }
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

    BusyIndicator {
        running: isConnecting
        visible: running

        height: sf(48)
        width: height
        anchors.centerIn: parent

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: buttonTextColor
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: deviceDelegate

        Rectangle {
            id: delegateRect

            width: ListView.view.width
            height: deviceLayout.height

            opacity: parent.enabled ? 1.0 : 0.7
            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

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

                        ColorOverlay {
                            anchors.fill: deviceImage
                            source: deviceImage
                            color: currentDevice && (currentDevice.name === name) ? buttonTextColor : !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        }
                    }

                    Item {
                        width: sf(2)
                    }

                    Text {
                        Layout.fillWidth: true

                        text: isConnecting && currentDevice && (currentDevice.name === name) ? "Connecting..." : name
                        font.pixelSize: baseFontSize * 0.9
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: currentDevice && (currentDevice.name === name) ? buttonTextColor : !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
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
                        color: currentDevice && (currentDevice.name === name) ? buttonTextColor : !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
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
                    if (!currentDevice || currentDevice.name !== name) {
                        app.settings.setValue("device", name);

                        deviceListView.currentIndex = index;
                        deviceSelected(name, discoveryAgent.devices.get(index));
                    } else {
                        app.settings.remove("device");

                        deviceListView.currentIndex = -1;
                        disconnect();

                        if (discoverySwitch.checked) {
                            discoveryAgent.start();
                        }
                    }
                }

                Component.onCompleted: {
                    var stored = app.settings.value("device", "");

                    if (stored > "" && stored === name && (!currentDevice || !currentDevice.connected)) {
                        deviceListView.currentIndex = index;
                        deviceSelected(name, discoveryAgent.devices.get(index));
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    DeviceDiscoveryAgent {
        id: discoveryAgent

        deviceFilter: function(device) {
            var types = [];

            if (bluetoothCheckBox.checked) {
                types.push(Device.DeviceTypeBluetooth);
            }

            if (usbCheckBox.checked) {
                types.push(Device.DeviceTypeSerialPort);
            }

            for (var i in types) {
                if (device.deviceType === types[i]) {
                    return true;
                }
            }

            return false;
        }

        onDeviceDiscovered: {
            console.log("Device discovered: ", device.name);
        }

        onDiscoverDevicesCompleted: {
            console.log("Device discovery completed");
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onStateChanged: {
            switch (tcpSocket.state) {
            case AbstractSocket.StateUnconnected:
                isConnected = false;
                isConnecting = false;
                break;
            case AbstractSocket.StateHostLookup:
                isConnected = false;
                isConnecting = true;
                break;
            case AbstractSocket.StateConnecting:
                isConnected = false;
                isConnecting = true;
                break;
            case AbstractSocket.StateConnected:
                console.log("Connected to", tcpSocket.remoteName, tcpSocket.remotePort)
                isConnected = true;
                isConnecting = false;
                break;
            case AbstractSocket.StateBound:
                break;
             case AbstractSocket.StateListening:
                break;
             case AbstractSocket.StateClosing:
                 isConnected = false;
                 isConnecting = false;
                 break;
            }
        }

        onErrorChanged: {
            console.log("Connection error", tcpSocket.error, tcpSocket.errorString)

            errorDialog.text = tcpSocket.errorString;
            errorDialog.open();

            isConnected = false;
            isConnecting = false;
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onConnectedChanged: {
            if (currentDevice) {
                console.log("Device connected changed:", currentDevice.name, currentDevice.connected);

                if (!currentDevice.connected) {
                    if (deviceListView.currentIndex != -1) {
                        deviceConnectionTimer.interval = 5000;
                        deviceConnectionTimer.start();
                    }
                }
            }
        }

        onErrorChanged: {
            if (currentDevice) {
                console.log("Connection error:", currentDevice.error)

                deviceConnectionTimer.stop();
                deviceConnectionCheckTimer.stop();

                errorDialog.text = currentDevice.error;
                errorDialog.open();

                isConnected = false;
                isConnecting = false;
                currentDevice = null;

                if (discoverySwitch.checked) {
                    discoveryAgent.start();
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: deviceConnectionTimer

        interval: 5000
        running: false
        repeat: false

        onRunningChanged: {
            if (running) {
                isConnected = false;
                isConnecting = true;
                discoveryAgent.stop();
            }
        }

        onTriggered: {
            // try to connect
            if (currentDevice) {
                currentDevice.connected = true;
                deviceConnectionCheckTimer.running = true;
            }
        }
    }

    Timer {
        id: deviceConnectionCheckTimer

        interval: 10000
        running: false
        repeat: false

        onTriggered: {
            // check if connection attempt was successful
            if (currentDevice && currentDevice.connected === true) {
                isConnected = true;
                isConnecting = false;
                discoveryAgent.stop();
            } else if (discoverySwitch.checked) {
                isConnected = false;
                isConnecting = false;
                discoveryAgent.start();
            }
        }
    }

    // -------------------------------------------------------------------------

    Dialog {
        id: errorDialog

        property alias text: label.text

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true

        standardButtons: Dialog.Ok
        title: qsTr("Unable to connect");
        text: ""

        Label {
            id: label

            Layout.fillWidth: true
            font.pixelSize: baseFontSize
            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
        }
    }

    //--------------------------------------------------------------------------
}
