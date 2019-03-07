import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

import "./controls"

Item {
    id: gnssManager

    property App app
    property StackView stackView

    property alias title: locationSettingsTab.title

    property alias gnssSettings: gnssSettings
    property alias positionSourceManager: positionSourceManager
    property alias settingsTabContainer: settingsTabContainer
    property alias locationSettingsTab: locationSettingsTab // XXX remove direct references to this

    property color foregroundColor: "#000000"
    property color secondaryForegroundColor: "#007ac2"
    property color backgroundColor: "#e1f0fb"
    property color secondaryBackgroundColor: "#e1f0fb"
    property color selectedBackgroundColor: "#FAFAFA"
    property color hoverBackgroundColor: "#e1f0fb"
    property color dividerColor: "#c0c0c0"

    property string fontFamily: Qt.application.font.family

    property bool showAboutDevice: true
    property bool showAlerts: true
    property bool showAntennaHeight: true
    property bool showAltitude: true

    property alias isConnecting: positionSourceManager.isConnecting
    property alias isConnected: positionSourceManager.isConnected
    property alias stayConnected: positionSourceManager.stayConnected

    signal showLocationSettings()
    signal startPositionSource()
    signal stopPositionSource()
    signal newPosition(var position)

    //-------------------------------------------------------------------------

    // needed for ConfirmPanel to appear in the correct location
    anchors.fill: parent

    //-------------------------------------------------------------------------

    onShowLocationSettings: {
        stackView.push(settingsTabContainer, {
                           settingsTab: locationSettingsTab,
                           title: locationSettingsTab.title,
                           settingsComponent: locationSettingsTab.contentComponent,
                       });

    }

    //-------------------------------------------------------------------------

    onStartPositionSource: {
        positionSourceManager.startPositionSource();
    }

    //-------------------------------------------------------------------------

    onStopPositionSource: {
        positionSourceManager.stopPositionSource();
    }

    // Position source management ---------------------------------------------

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

    // UI Components -----------------------------------------------------------

    SettingsTabContainer {
        id: settingsTabContainer
    }

    //--------------------------------------------------------------------------

    SettingsTabLocation {
        id: locationSettingsTab

        Layout.fillHeight: true
        Layout.fillWidth: true

        title: qsTr("Location Provider")

        stackView: gnssManager.stackView
        gnssSettings: gnssManager.gnssSettings
        positionSourceManager: gnssManager.positionSourceManager

        foregroundColor: gnssManager.foregroundColor
        secondaryForegroundColor: gnssManager.secondaryForegroundColor
        backgroundColor: gnssManager.backgroundColor
        secondaryBackgroundColor: gnssManager.secondaryBackgroundColor
        hoverBackgroundColor: gnssManager.hoverBackgroundColor
        selectedBackgroundColor: gnssManager.selectedBackgroundColor
        dividerColor: gnssManager.dividerColor
        fontFamily: gnssManager.fontFamily

        showAboutDevice: gnssManager.showAboutDevice
        showAlerts: gnssManager.showAlerts
        showAntennaHeight: gnssManager.showAntennaHeight
        showAltitude: gnssManager.showAltitude
    }

    //--------------------------------------------------------------------------

    ConfirmPanel {
        id: connectionErrorDialog

        function showError(message) {
            connectionErrorDialog.clear();
            connectionErrorDialog.icon = "images/warning.png";
            connectionErrorDialog.title = qsTr("Unable to connect");
            connectionErrorDialog.text = message;
            connectionErrorDialog.button1Text = qsTr("Ok");
            connectionErrorDialog.button2Text = "";
            connectionErrorDialog.show();
        }
    }

    //--------------------------------------------------------------------------

    GNSSAlerts {
        id: gnssAlerts

        gnssSettings: gnssSettings
    }

    // GNSS settings------------------------------------------------------------

    GNSSSettings {
        id: gnssSettings

        app: gnssManager.app
    }

    //--------------------------------------------------------------------------
}
