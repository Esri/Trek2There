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

import ArcGIS.AppFramework.Positioning 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0

Item {
    readonly property var eConnectionType: {
        "internal": 0,
        "external": 1,
        "network": 2
    }

    property alias positionSource: positionSource
    property alias satelliteInfoSource: satelliteInfoSource
    property alias nmeaSource: nmeaSource
    property alias tcpSocket: tcpSocket
    property alias discoveryAgent: discoveryAgent

    property string storedDevice

    property Device currentDevice
    property bool isConnecting
    property bool isConnected
    property int connectionType: eConnectionType.internal

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal disconnect()

    //--------------------------------------------------------------------------

    PositionSource {
        id: positionSource

        active: true
        nmeaSource: nmeaSource.source ? nmeaSource : null
    }

    //--------------------------------------------------------------------------

    SatelliteInfoSource {
        id: satelliteInfoSource

        active: true
        nmeaSource: nmeaSource //nmeaSource.source ? nmeaSource : null
    }

    //--------------------------------------------------------------------------

    NmeaSource {
        id: nmeaSource

        onReceivedNmeaData: {
            if (!isConnected && receivedSentence.trim() > "") {
                isConnected = true;
                isConnecting = false;
            }
        }
    }

    //--------------------------------------------------------------------------

    TcpSocket {
        id: tcpSocket

        onErrorChanged: disconnect()
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onConnectedChanged: {
            // cleanup in case the connection to the device is lost
            if (currentDevice && !currentDevice.connected) {
                disconnect();
            }
        }

        onErrorChanged:  {
            if (currentDevice) {
                disconnect();
            }
        }
    }

    //--------------------------------------------------------------------------

    DeviceDiscoveryAgent {
        id: discoveryAgent

        property bool detectBluetooth: true
        property bool detectSerialPort: false

        deviceFilter: function(device) { return filter(device); }

        onDeviceDiscovered: {
            if (filter(device)) {
                console.log("Device discovered: ", device.name);

                if (!isConnecting && !isConnected && storedDevice > "" && storedDevice === device.name) {
                    deviceSelected(device);
                }
            }
        }

        onErrorChanged: {
            console.log("DeviceDiscoveryAgent error", error)
        }

        onRunningChanged: {
            console.log("DeviceDiscoveryAgent running", running)
        }

        onDiscoverDevicesCompleted: {
            console.log("Device discovery completed");
            stop();
        }

        function filter(device) {
            var types = [];

            if (detectBluetooth) {
                types.push(Device.DeviceTypeBluetooth);
            }

            if (detectSerialPort) {
                types.push(Device.DeviceTypeSerialPort);
            }

            for (var i in types) {
                if (device.deviceType === types[i]) {
                    return true;
                }
            }

            return false;
        }
    }

    //--------------------------------------------------------------------------

    onNetworkHostSelected: {
        console.log("Connecting to remote host:", hostname, "port:", port);

        disconnect();

        isConnected = false;
        isConnecting = true;

        nmeaSource.source = tcpSocket;
        connectionType = eConnectionType.network;
        tcpSocket.connectToHost(hostname, port);
    }

    //--------------------------------------------------------------------------

    onDeviceSelected: {
        console.log("Connecting to device:", device.name, "address:", device.address, "type:", device.deviceType, device);

        disconnect();

        isConnected = false;
        isConnecting = true;

        currentDevice = device;
        nmeaSource.source = currentDevice;
        connectionType = eConnectionType.external;
        currentDevice.connected = true;
    }

    //--------------------------------------------------------------------------

    onDisconnect: {
        if (tcpSocket.valid && tcpSocket.state === AbstractSocket.StateConnected) {
            tcpSocket.disconnectFromHost();
        }

        if (currentDevice && currentDevice.connected) {
            currentDevice.connected = false;
        }

        isConnected = false;
        isConnecting = false;

        nmeaSource.source = null;
        connectionType = eConnectionType.internal;
    }

    //--------------------------------------------------------------------------

    onIsConnectedChanged: {
        if (isConnected) {
            if (connectionType === eConnectionType.external) {
                console.log("Connected to device:", currentDevice.name, "address:", currentDevice.address);
            } else if (connectionType === eConnectionType.network) {
                console.log("Connected to remote host:", tcpSocket.remoteName, "port:", tcpSocket.remotePort)
            }
        } else {
            if (connectionType === eConnectionType.external) {
                console.log("Disconnecting device:", currentDevice.name, "address", currentDevice.address);
            } else if (connectionType === eConnectionType.network) {
                console.log("Disconnecting from remote host:", tcpSocket.remoteName, "port:", tcpSocket.remotePort);
            }
        }
    }

    //--------------------------------------------------------------------------
}
