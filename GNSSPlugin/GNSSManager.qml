import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

import "./GNSSManager"
import "./controls"

Item {
    id: gnssManager

    property App app

    property alias gnssSettings: gnssSettings
    property alias positionSourceManager: positionSourceManager

    property alias isConnecting: positionSourceManager.isConnecting
    property alias isConnected: positionSourceManager.isConnected
    property alias stayConnected: positionSourceManager.stayConnected
    readonly property bool isReady: positionSourceManager.status == positionSourceManager.kStatusInUse

    signal startPositionSource()
    signal stopPositionSource()
    signal newPosition(var position)

    //-------------------------------------------------------------------------

    // needed for ConfirmPanel to appear in the correct location
    anchors.fill: parent

    // make sure alerts are on top
    z: 9999

    //-------------------------------------------------------------------------

    onStartPositionSource: {
        positionSourceManager.startPositionSource();
    }

    //-------------------------------------------------------------------------

    onStopPositionSource: {
        positionSourceManager.stopPositionSource();
    }

    //-------------------------------------------------------------------------

    PositionSourceManager {
        id: positionSourceManager

        discoverBluetooth: gnssSettings.discoverBluetooth
        discoverBluetoothLE: gnssSettings.discoverBluetoothLE
        discoverSerialPort: gnssSettings.discoverSerialPort

        connectionType: gnssSettings.locationSensorConnectionType
        storedDeviceName: gnssSettings.lastUsedDeviceName
        storedDeviceJSON: gnssSettings.lastUsedDeviceJSON
        hostname: gnssSettings.hostname
        port: Number(gnssSettings.port)

        altitudeType: gnssSettings.locationAltitudeType
        customGeoidSeparation: gnssSettings.locationGeoidSeparation
        antennaHeight: gnssSettings.locationAntennaHeight

        onNewPosition: {
            gnssManager.newPosition(position);
        }

        onError: {
            connectionErrorDialog.showError(errorString);
        }
    }

    //--------------------------------------------------------------------------

    PositionSourceMonitor {
        id: positionSourceMonitor

        positionSourceManager: positionSourceManager

        maximumDataAge: gnssSettings.locationMaximumDataAge
        maximumPositionAge: gnssSettings.locationMaximumPositionAge

        onAlert: {
            gnssAlerts.positionSourceAlert(alertType);
        }
    }

    //--------------------------------------------------------------------------

    GNSSAlerts {
        id: gnssAlerts

        gnssSettings: gnssSettings
    }

    //--------------------------------------------------------------------------

    GNSSSettings {
        id: gnssSettings

        app: gnssManager.app
    }

    //--------------------------------------------------------------------------

    ConfirmPanel {
        id: connectionErrorDialog

        function showError(message) {
            connectionErrorDialog.clear();
            connectionErrorDialog.icon = "./images/warning.png";
            connectionErrorDialog.title = qsTr("Unable to connect");
            connectionErrorDialog.text = message;
            connectionErrorDialog.button1Text = qsTr("Ok");
            connectionErrorDialog.button2Text = "";
            connectionErrorDialog.show();
        }
    }

    //--------------------------------------------------------------------------
}
