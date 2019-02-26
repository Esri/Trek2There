/* Copyright 2017 Esri
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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

import "../GNSSPlugin"
import "../GNSSPlugin/controls"

Item {
    id: mainView

    property App app

    property alias controller: controller
    property alias gnssSettings: gnssSettings
    property alias mainStackView: mainStackView

    //--------------------------------------------------------------------------

    StackView {
        id: mainStackView

        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true

        // initialItem: (showSafetyWarning === true || safetyWarningAccepted === false) ? disclaimerView : navigationView // disabled for v1.0
        initialItem: disclaimerView
    }

    //--------------------------------------------------------------------------

    Component {
        id: disclaimerView

        DisclaimerView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: navigationView

        NavigationView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: settingsView

        SettingsView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: devicesView

        DevicesView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: aboutView

        AboutView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // External position sources -----------------------------------------------

    PositioningSources {
        id: sources

        connectionType: controller.connectionType
        discoverBluetooth: controller.discoverBluetooth
        discoverBluetoothLE: controller.discoverBluetoothLE
        discoverSerialPort: controller.discoverSerialPort
    }

    PositioningSourcesController {
        id: controller

        sources: sources
        stayConnected: true

        discoverBluetooth: gnssSettings.discoverBluetooth
        discoverBluetoothLE: gnssSettings.discoverBluetoothLE
        discoverSerialPort: gnssSettings.discoverSerialPort

        connectionType: gnssSettings.locationSensorConnectionType
        storedDeviceName: gnssSettings.lastUsedDeviceName
        storedDeviceJSON: gnssSettings.lastUsedDeviceJSON
        hostname: gnssSettings.hostname
        port: Number(gnssSettings.port)
    }

    // -------------------------------------------------------------------------

    GNSSSettings {
        id: gnssSettings

        app: mainView.app

        defaultLocationAlertsVisualExternal: false
        defaultLocationAlertsSpeechExternal: false
        defaultLocationAlertsVibrateExternal: false
    }

    //--------------------------------------------------------------------------
}
