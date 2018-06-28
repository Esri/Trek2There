import QtQuick 2.9
import QtQuick.Controls 2.2

import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    property PositioningSources sources

    property PositionSource positionSource: sources.positionSource
    property SatelliteInfoSource  satelliteInfoSource: sources.satelliteInfoSource
    property NmeaSource nmeaSource: sources.nmeaSource
    property TcpSocket tcpSocket: sources.tcpSocket
    property DeviceDiscoveryAgent discoveryAgent: sources.discoveryAgent
    property Device currentDevice: sources.currentDevice

    property bool isConnecting: sources.isConnecting
    property bool isConnected: sources.isConnected

    property bool discoverBluetooth: app.settings.boolValue("discoverBluetooth", true)
    property bool discoverSerialPort: app.settings.boolValue("discoverSerialPort", false)
    property string storedDevice: app.settings.value("device", "");
    property string hostname: app.settings.value("hostname", "");
    property int port: app.settings.numberValue("port", "");
    property int connectionType: app.settings.numberValue("connectionType", sources.eConnectionType.internal);

    readonly property bool useInternalGPS: connectionType === sources.eConnectionType.internal
    readonly property bool useExternalGPS: connectionType === sources.eConnectionType.external
    readonly property bool useTCPConnection: connectionType === sources.eConnectionType.network

    readonly property string name: useInternalGPS ? positionSource.name :
                                   useExternalGPS ? (currentDevice ? currentDevice.name : storedDevice > "" ? storedDevice : "Unknown") :
                                                    (tcpSocket.remoteName && tcpSocket.remotePort ? tcpSocket.remoteName + ":" + tcpSocket.remotePort : (hostname > "" && port > "" ? hostname + ":" + port : "Unknown"))

    property bool initialized

    signal reconnect()

    // -------------------------------------------------------------------------

    Component.onCompleted: {
        connectionType = app.settings.value("connectionType", sources.eConnectionType.internal);
        initialized = true;
    }

    // -------------------------------------------------------------------------

    onReconnect: {
        if (useExternalGPS && storedDevice > "") {
            if (!isConnecting && !isConnected) {
                discoveryAgentRepeatTimer.start();
            } else {
                discoveryAgent.stop();
            }
        } else if (useTCPConnection && hostname > "" && port > "") {
            if (!isConnecting && !isConnected) {
                sources.networkHostSelected(hostname, port);
            }
            discoveryAgent.stop();
        } else {
            discoveryAgent.stop();
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: app.settings

        onValueChanged: {
            storedDevice = app.settings.value("device", "")
            hostname = app.settings.value("hostname", "")
            port = app.settings.value("port", "")
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverBluetoothChanged: {
        if (initialized) {
            app.settings.setValue("discoverBluetooth", discoverBluetooth);
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverSerialPortChanged: {
        if (initialized) {
            app.settings.setValue("discoverSerialPort", discoverSerialPort);
        }
    }

    // -------------------------------------------------------------------------

    onConnectionTypeChanged: {
        if (initialized) {
            app.settings.setValue("connectionType", connectionType);
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onErrorChanged: {
            console.log("TCP connection error:", tcpSocket.error, tcpSocket.errorString)

            errorDialog.text = tcpSocket.errorString;
            errorDialog.open();
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onErrorChanged: {
            if (currentDevice) {
                console.log("Device connection error:", currentDevice.error)

                errorDialog.text = currentDevice.error;
                errorDialog.open();
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: discoveryAgent

        property string lastError

        onErrorChanged: {
            if (discoveryAgent.error !== lastError) {
                console.log("Device discovery agent error:", discoveryAgent.error)

                errorDialog.text = discoveryAgent.error;
                errorDialog.open();

                lastError = discoveryAgent.error;
            }
        }
    }

    // -------------------------------------------------------------------------

    Dialog {
        id: errorDialog

        property alias text: errorMessage.text

        x: (app.width - width) / 2
        y: (app.height - height) / 2
        modal: true

        standardButtons: Dialog.Ok
        title: qsTr("Unable to connect");
        text: ""

        Text {
            id: errorMessage

            width: errorDialog.width
            wrapMode: Text.WordWrap
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: discoveryAgentRepeatTimer

        interval: 2000
        running: false
        repeat: false

        onTriggered: {
            if (!discoveryAgent.running) {
                discoveryAgent.start();
            }
        }
    }

    //--------------------------------------------------------------------------
}
