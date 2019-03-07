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

import ArcGIS.AppFramework 1.0

QtObject {
    property App app
    property Settings settings: app.settings

    //--------------------------------------------------------------------------

    // default settings
    property bool defaultDiscoverBluetooth: true
    property bool defaultDiscoverBluetoothLE: false
    property bool defaultDiscoverSerialPort: false

    property bool defaultLocationAlertsVisualInternal: false
    property bool defaultLocationAlertsSpeechInternal: false
    property bool defaultLocationAlertsVibrateInternal: false

    property bool defaultLocationAlertsVisualExternal: true
    property bool defaultLocationAlertsSpeechExternal: true
    property bool defaultLocationAlertsVibrateExternal: true

    property int defaultLocationMaximumDataAge: 5000
    property int defaultLocationMaximumPositionAge: 5000
    property int defaultLocationSensorConnectionType: kConnectionTypeInternal
    property int defaultLocationAltitudeType: kAltitudeTypeMSL

    property real defaultLocationGeoidSeparation: Number.NaN
    property real defaultLocationAntennaHeight: Number.NaN

    // current settings state
    property bool discoverBluetooth: defaultDiscoverBluetooth
    property bool discoverBluetoothLE: defaultDiscoverBluetoothLE
    property bool discoverSerialPort: defaultDiscoverSerialPort

    property bool locationAlertsVisual: defaultLocationAlertsVisualInternal
    property bool locationAlertsSpeech: defaultLocationAlertsSpeechInternal
    property bool locationAlertsVibrate: defaultLocationAlertsVibrateInternal

    property int locationMaximumDataAge: defaultLocationMaximumDataAge
    property int locationMaximumPositionAge: defaultLocationMaximumPositionAge
    property int locationSensorConnectionType: defaultLocationSensorConnectionType
    property int locationAltitudeType: defaultLocationAltitudeType

    property real locationGeoidSeparation: defaultLocationGeoidSeparation
    property real locationAntennaHeight: defaultLocationAntennaHeight

    property string lastUsedDeviceLabel: ""
    property string lastUsedDeviceName: ""
    property string lastUsedDeviceJSON: ""
    property string hostname: ""
    property string port: ""

    property var knownDevices: ({})

    //--------------------------------------------------------------------------

    readonly property string kInternalPositionSourceName: "IntegratedProvider"
    readonly property string kInternalPositionSourceNameTranslated: qsTr("Integrated Provider")

    readonly property string kKeyLocationPrefix: "Location/"
    readonly property string kKeyLocationKnownDevices: kKeyLocationPrefix + "knownDevices"
    readonly property string kKeyLocationLastUsedDevice: kKeyLocationPrefix + "lastUsedDevice"
    readonly property string kKeyLocationDiscoverBluetooth: kKeyLocationPrefix + "discoverBluetooth"
    readonly property string kKeyLocationDiscoverBluetoothLE: kKeyLocationPrefix + "discoverBluetoothLE"
    readonly property string kKeyLocationDiscoverSerialPort: kKeyLocationPrefix + "discoverSerialPort"

    readonly property int kConnectionTypeInternal: 0
    readonly property int kConnectionTypeExternal: 1
    readonly property int kConnectionTypeNetwork: 2

    readonly property int kAltitudeTypeMSL: 0
    readonly property int kAltitudeTypeHAE: 1

    //--------------------------------------------------------------------------

    property bool updating

    signal receiverListUpdated()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        read();
    }

    //--------------------------------------------------------------------------

    // update the current global settings on receiver change
    onLastUsedDeviceNameChanged: {
        updating = true;

        if (knownDevices && lastUsedDeviceName > "") {
            var receiverSettings = knownDevices[lastUsedDeviceName];

            if (receiverSettings) {
                switch (receiverSettings.connectionType) {
                case kConnectionTypeInternal:
                    lastUsedDeviceLabel = receiverSettings.label;
                    lastUsedDeviceJSON = "";
                    hostname = "";
                    port = "";
                    break;
                case kConnectionTypeExternal:
                    lastUsedDeviceLabel = receiverSettings.label;
                    lastUsedDeviceJSON = receiverSettings.receiver > "" ? JSON.stringify(receiverSettings.receiver) : "";
                    hostname = "";
                    port = "";
                    break;
                case kConnectionTypeNetwork:
                    lastUsedDeviceLabel = receiverSettings.label;
                    lastUsedDeviceJSON = ""
                    hostname = receiverSettings.hostname;
                    port = receiverSettings.port;
                    break;
                default:
                    console.log("Error: unknown connectionType", receiverSettings.connectionType);
                    updating = false;
                    return;
                }

                locationAlertsVisual = receiverSettings.locationAlertsVisual ? receiverSettings.locationAlertsVisual : defaultLocationAlertsVisualInternal;
                locationAlertsSpeech = receiverSettings.locationAlertsSpeech ? receiverSettings.locationAlertsSpeech : defaultLocationAlertsSpeechInternal;
                locationAlertsVibrate = receiverSettings.locationAlertsVibrate ? receiverSettings.locationAlertsVibrate : defaultLocationAlertsVibrateInternal;
                locationMaximumDataAge = receiverSettings.locationMaximumDataAge ? receiverSettings.locationMaximumDataAge : defaultLocationMaximumDataAge;
                locationMaximumPositionAge = receiverSettings.locationMaximumPositionAge ? receiverSettings.locationMaximumPositionAge : defaultLocationMaximumPositionAge;
                locationSensorConnectionType = receiverSettings.connectionType ? receiverSettings.connectionType : defaultLocationSensorConnectionType;
                locationAltitudeType = receiverSettings.altitudeType ? receiverSettings.altitudeType : defaultLocationAltitudeType;
                locationGeoidSeparation = receiverSettings.geoidSeparation ? receiverSettings.geoidSeparation : defaultLocationGeoidSeparation;
                locationAntennaHeight = receiverSettings.antennaHeight ? receiverSettings.antennaHeight : defaultLocationAntennaHeight;
            }
        }

        updating = false;
    }

    //--------------------------------------------------------------------------

    function read() {
        console.log("Reading GNSS settings");

        discoverBluetooth = settings.boolValue(kKeyLocationDiscoverBluetooth, defaultDiscoverBluetooth);
        discoverBluetoothLE = settings.boolValue(kKeyLocationDiscoverBluetoothLE, defaultDiscoverBluetoothLE);
        discoverSerialPort = settings.boolValue(kKeyLocationDiscoverSerialPort, defaultDiscoverSerialPort);

        try {
            knownDevices = JSON.parse(settings.value(kKeyLocationKnownDevices, "{}"));
        } catch (e) {
            console.log("Error while parsing settings file.", e);
        }

        var internalFound = false;
        for (var deviceName in knownDevices) {
            // add default internal position source if necessary
            if (deviceName === kInternalPositionSourceName) {
                internalFound = true;
                break;
            }
        }

        if (!internalFound) {
            createInternalSettings();
        } else {
            // update the label of the internal position source provider in case the system
            // language has changed since last using the app
            var receiverSettings = knownDevices[kInternalPositionSourceName];
            if (receiverSettings && receiverSettings["label"] !== kInternalPositionSourceNameTranslated) {
                receiverSettings["label"] = kInternalPositionSourceNameTranslated;
            }

            // this triggers an update of the global settings using the last known receiver
            lastUsedDeviceName = settings.value(kKeyLocationLastUsedDevice, kInternalPositionSourceName)
        }

        log();
    }

    //--------------------------------------------------------------------------

    function write() {
        console.log("Writing app settings");

        settings.setValue(kKeyLocationDiscoverBluetooth, discoverBluetooth, defaultDiscoverBluetooth);
        settings.setValue(kKeyLocationDiscoverBluetoothLE, discoverBluetoothLE, defaultDiscoverBluetoothLE);
        settings.setValue(kKeyLocationDiscoverSerialPort, discoverSerialPort, defaultDiscoverSerialPort);

        settings.setValue(kKeyLocationLastUsedDevice, lastUsedDeviceName, kInternalPositionSourceName);
        settings.setValue(kKeyLocationKnownDevices, JSON.stringify(knownDevices), ({}));

        log();
    }

    //--------------------------------------------------------------------------

    function log() {
        console.log("GNSS settings -");

        console.log("* discoverBluetooth:", discoverBluetooth);
        console.log("* discoverBluetoothLE:", discoverBluetoothLE);
        console.log("* discoverSerialPort:", discoverSerialPort);

        console.log("* locationAlertsVisual:", locationAlertsVisual);
        console.log("* locationAlertsSpeech:", locationAlertsSpeech);
        console.log("* locationAlertsVibrate:", locationAlertsVibrate);

        console.log("* locationMaximumDataAge:", locationMaximumDataAge);
        console.log("* locationMaximumPositionAge:", locationMaximumPositionAge);
        console.log("* locationSensorConnectionType:", locationSensorConnectionType);
        console.log("* locationAltitudeType:", locationAltitudeType);

        console.log("* locationGeoidSeparation:", locationGeoidSeparation);
        console.log("* locationAntennaHeight:", locationAntennaHeight);

        console.log("* lastUsedDeviceName:", lastUsedDeviceName);
        console.log("* lastUsedDeviceLabel:", lastUsedDeviceLabel);

        console.log("* knownDevices:", JSON.stringify(knownDevices));
    }

    //--------------------------------------------------------------------------

    function createDefaultSettingsObject(connectionType) {
        return {
            "locationAlertsVisual": connectionType === kConnectionTypeInternal ? defaultLocationAlertsVisualInternal : defaultLocationAlertsVisualExternal,
            "locationAlertsSpeech": connectionType === kConnectionTypeInternal ? defaultLocationAlertsSpeechInternal : defaultLocationAlertsSpeechExternal,
            "locationAlertsVibrate": connectionType === kConnectionTypeInternal ? defaultLocationAlertsVibrateInternal : defaultLocationAlertsVibrateExternal,
            "locationMaximumDataAge": defaultLocationMaximumDataAge,
            "locationMaximumPositionAge": defaultLocationMaximumPositionAge,
            "altitudeType": defaultLocationAltitudeType,
            "antennaHeight": defaultLocationAntennaHeight,
            "geoidSeparation": defaultLocationGeoidSeparation,
            "connectionType": connectionType
        }
    }

    function createInternalSettings() {
        if (knownDevices) {
            // use the fixed internal provider name as the identifier
            var name = kInternalPositionSourceName;

            if (!knownDevices[name]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeInternal);

                // use the localised internal provider name as the label
                receiverSettings["label"] = kInternalPositionSourceNameTranslated;

                knownDevices[name] = receiverSettings;
                receiverListUpdated();
            }

            lastUsedDeviceName = name;

            return name;
        }

        return "";
    }

    function createExternalReceiverSettings(deviceName, device) {
        if (knownDevices && device && deviceName > "") {
            if (!knownDevices[deviceName]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeExternal);
                receiverSettings["receiver"] = device;
                receiverSettings["label"] = deviceName;

                knownDevices[deviceName] = receiverSettings;
                receiverListUpdated();
            }

            lastUsedDeviceName = deviceName;

            return deviceName;
        }

        return "";
    }

    function createNetworkSettings(hostname, port) {
        if (knownDevices && hostname > "" && port > "") {
            var networkAddress = hostname + ":" + port;

            if (!knownDevices[networkAddress]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeNetwork);
                receiverSettings["hostname"] = hostname;
                receiverSettings["port"] = port;
                receiverSettings["label"] = networkAddress;

                knownDevices[networkAddress] = receiverSettings;
                receiverListUpdated();
            }

            lastUsedDeviceName = networkAddress;

            return networkAddress;
        }

        return "";
    }

    function deleteKnownDevice(deviceName) {
        try {
            delete knownDevices[deviceName];
            receiverListUpdated();
        }
        catch(e){
            console.log(e);
        }
    }

    //--------------------------------------------------------------------------
}
