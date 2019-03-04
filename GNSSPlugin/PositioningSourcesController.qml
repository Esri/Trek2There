import QtQuick 2.9
import QtQuick.Controls 2.2

import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    readonly property var eConnectionType: {
        "internal": 0,
        "external": 1,
        "network": 2
    }

    property PositioningSources sources

    readonly property PositionSource positionSource: sources.positionSource
    readonly property SatelliteInfoSource satelliteInfoSource: sources.satelliteInfoSource
    readonly property NmeaSource nmeaSource: sources.nmeaSource
    readonly property TcpSocket tcpSocket: sources.tcpSocket
    readonly property DeviceDiscoveryAgent discoveryAgent: sources.discoveryAgent
    readonly property Device currentDevice: sources.currentDevice

    readonly property string currentNetworkAddress: sources.currentNetworkAddress
    readonly property string integratedProviderName: sources.integratedProviderName

    readonly property bool isConnecting: positionSource.valid && !useInternalGPS && sources.isConnecting
    readonly property bool isConnected: positionSource.valid && (useInternalGPS || sources.isConnected)

    property bool discoverBluetooth: true
    property bool discoverBluetoothLE: false
    property bool discoverSerialPort: false

    property int connectionType: eConnectionType.internal
    property string storedDeviceName: ""
    property string storedDeviceJSON: ""
    property string hostname: ""
    property int port: Number.NaN

    readonly property bool useInternalGPS: connectionType === eConnectionType.internal
    readonly property bool useExternalGPS: connectionType === eConnectionType.external
    readonly property bool useTCPConnection: connectionType === eConnectionType.network

    readonly property string currentName:
        useInternalGPS ? integratedProviderName :
        useExternalGPS && currentDevice ? currentDevice.name :
        useTCPConnection && currentNetworkAddress > "" ? currentNetworkAddress : ""

    readonly property string noExternalReceiverError: qsTr("No external GNSS receiver configured.")
    readonly property string noNetworkProviderError: qsTr("No network location provider configured.")

    property bool errorWhileConnecting
    property bool onSettingsPage
    property bool stayConnected
    property bool initialized

    signal startPositionSource()
    signal stopPositionSource()
    signal startDiscoveryAgent()
    signal stopDiscoveryAgent()
    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal deviceDeselected()
    signal disconnect()
    signal reconnect()
    signal fullDisconnect()

    // -------------------------------------------------------------------------

    Component.onCompleted: {
        // prepare to connect to device that was used previously
        if (storedDeviceJSON > "") {
            sources.currentDevice = Device.fromJson(storedDeviceJSON);
        }

        initialized = true;
    }

    // -------------------------------------------------------------------------

    onIsConnectedChanged: {
        if (initialized) {
            if (isConnected) {
                if (connectionType === eConnectionType.external && currentDevice) {
                    console.log("Connected to device:", currentDevice.name, "address:", currentDevice.address);
                } else if (connectionType === eConnectionType.network) {
                    console.log("Connected to remote host:", tcpSocket.remoteName, "port:", tcpSocket.remotePort);
                } else if (connectionType === eConnectionType.internal) {
                    console.log("Connected to system location source:", integratedProviderName);
                }

                errorWhileConnecting = false;
            } else {
                if (connectionType === eConnectionType.external && currentDevice) {
                    console.log("Disconnecting device:", currentDevice.name, "address", currentDevice.address);
                } else if (connectionType === eConnectionType.network) {
                    console.log("Disconnecting from remote host:", tcpSocket.remoteName, "port:", tcpSocket.remotePort);
                } else if (connectionType === eConnectionType.internal) {
                    console.log("Disconnecting from system location source:", integratedProviderName);
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    onReconnect: {
        if (!reconnectTimer.running) {
            reconnectTimer.start();
        }
    }

    function reconnectNow() {
        if (useExternalGPS) {
            if (!discoveryAgent.running && !isConnecting && !isConnected) {
                if (currentDevice) {
                    deviceSelected(currentDevice)
                } else if (!onSettingsPage) {
                    connectionErrorDialog.showError(noExternalReceiverError);
                }
            }
        } else if (useTCPConnection) {
            if (!isConnecting && !isConnected) {
                if (hostname > "" && port > "") {
                    sources.networkHostSelected(hostname, port);
                } else if (!onSettingsPage) {
                    connectionErrorDialog.showError(noNetworkProviderError);
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    onStartPositionSource:  {
        positionSource.start();
    }

    // -------------------------------------------------------------------------

    onStopPositionSource:  {
        positionSource.stop();
    }

    // -------------------------------------------------------------------------

    onStartDiscoveryAgent: {
        discoveryTimer.start();
    }

    // -------------------------------------------------------------------------

    onStopDiscoveryAgent: {
        discoveryAgent.stop();
    }

    // -------------------------------------------------------------------------

    onNetworkHostSelected: {
        sources.networkHostSelected(hostname, port);
    }

    // -------------------------------------------------------------------------

    onDeviceSelected: {
        sources.deviceSelected(device);
    }

    // -------------------------------------------------------------------------

    onDeviceDeselected: {
        sources.disconnect();
    }

    // -------------------------------------------------------------------------

    onDisconnect: {
        sources.disconnect();
    }

    // -------------------------------------------------------------------------

    onFullDisconnect: {
        sources.disconnect();
        discoveryAgent.stop();
        discoveryTimer.stop();
        reconnectTimer.stop();
    }

    // -------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onErrorChanged: {
            if (useTCPConnection) {
                console.log("TCP connection error:", tcpSocket.error, tcpSocket.errorString)
                connectionErrorDialog.showError(tcpSocket.errorString);

//                if (stayConnected && !onSettingsPage) {
//                    errorWhileConnecting = true;
//                    reconnect();
//                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onConnectedChanged: {
            if (currentDevice && useExternalGPS) {
                if (stayConnected && !onSettingsPage) {
                    reconnect();
                }
            }
        }

        onErrorChanged: {
            if (currentDevice && useExternalGPS) {
                console.log("Device connection error:", currentDevice.error)

                // showing this dialog if we're not on the settings page proves too distracting
                if (onSettingsPage) {
                    connectionErrorDialog.showError(currentDevice.error);
                }

                if (stayConnected && !onSettingsPage) {
                    errorWhileConnecting = true;
                    reconnect();
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: discoveryAgent

        onDiscoverDevicesCompleted: {
            console.log("Device discovery completed");
        }

        onRunningChanged: {
            console.log("DeviceDiscoveryAgent running", discoveryAgent.running);
            if (useExternalGPS && !discoveryAgent.running && !isConnecting && !isConnected && stayConnected && !onSettingsPage) {
                if (!discoveryAgent.devices || discoveryAgent.devices.count == 0) {
                    discoveryTimer.start();
                }
            }
        }

        onErrorChanged: {
            console.log("Device discovery agent error:", discoveryAgent.error)
            if (useExternalGPS) {
                connectionErrorDialog.showError(discoveryAgent.error);
            }
        }

        onDeviceDiscovered: {
            if (discoveryAgent.filter(device)) {
                console.log("Device discovered - Name:", device.name, "Type:", device.deviceType);

                if (useExternalGPS && !isConnecting && !isConnected && storedDeviceName === device.name) {
                    deviceSelected(device);
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: reconnectTimer

        interval: 1000
        running: false
        repeat: false

        onTriggered: {
            reconnectNow();
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: discoveryTimer

        interval: 100
        running: false
        repeat: false

        onTriggered: {
            discoveryAgent.start();
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: connectionTimeOutTimer

        interval: 60000
        running: isConnecting
        repeat: false

        onTriggered: {
            console.log("Connection attempt timed out");
            fullDisconnect();
            reconnect();
        }
    }

    // -------------------------------------------------------------------------
}
