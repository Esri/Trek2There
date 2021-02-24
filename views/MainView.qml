/* Copyright 2021 Esri
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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtPositioning 5.15

import ArcGIS.AppFramework 1.0

import "../controls"
import "../GNSSPlugin"

Item {
    id: mainView

    property App app

    property alias gnssManager: gnssManager
    property alias gnssStatusPages: gnssStatusPages
    property alias gnssSettingsPages: gnssSettingsPages
    property alias stackView: mainStackView

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

            stackView: mainView.stackView
            gnssManager: mainView.gnssManager
            gnssStatusPages: mainView.gnssStatusPages
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: settingsView

        SettingsView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            gnssManager: mainView.gnssManager
            gnssSettingsPages: mainView.gnssSettingsPages
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

    //--------------------------------------------------------------------------

    // Manage connections to GNSS providers
    GNSSManager {
        id: gnssManager

        gnssSettingsPages: mainView.gnssSettingsPages
    }

    // GNSS settings UI
    GNSSSettingsPages {
        id: gnssSettingsPages

        title: qsTr("Location Provider")

        stackView: mainView.stackView
        gnssManager: mainView.gnssManager

        textColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
        selectedTextColor: buttonTextColor

        headerBarBackgroundColor: pageBackgroundColor
        headerBarTextColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
        pageBackgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
        listBackgroundColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

        fontFamily: Qt.application.font.family
        locale: Qt.locale()

        showInfoIcons: true
        showAboutDevice: true
        showAlerts: true
        showAntennaHeight: false
        showAltitude: false
        showAccuracy: false
    }

    // GNSS status UI
    GNSSStatusPages {
        id: gnssStatusPages

        stackView: mainView.stackView
        gnssManager: mainView.gnssManager
        gnssSettingsPages: mainView.gnssSettingsPages

        tabBarTabForegroundColor: buttonTextColor
        tabBarSelectedTabForegroundColor: !nightMode ? Qt.darker(tabBarTabForegroundColor, 1.25) : Qt.lighter(tabBarTabForegroundColor, 1.25)

        buttonBarBorderColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.background
        buttonBarButtonColor: buttonTextColor
        buttonBarBackgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.secondaryBackground
    }

    //--------------------------------------------------------------------------

    ClipboardDialog {
        id: clipboardDialog

        anchors.fill: parent

        onUseCoordinates: {
            if (clipLat !== "" && clipLon !== "") {
                console.log("lat: %1, lon:%2".arg(clipLat).arg(clipLon))
                requestedDestination = QtPositioning.coordinate(clipLat.toString(), clipLon.toString());
                dismissCoordinates();
            }
        }
    }


    // -------------------------------------------------------------------------

    Connections {
        id: appClipboard

        target: AppFramework.clipboard

        function onDataChanged() {
            checkClip();
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: Qt.application

        function onStateChanged() {
            // Needed for UWP
            if(safetyWarningAccepted && Qt.application.state === Qt.ApplicationActive) {
                checkClip();
            }
        }
    }

    // -------------------------------------------------------------------------

    function checkClip() {
        var lat = "";
        var lon = "";

        if (AppFramework.clipboard.dataAvailable && listenToClipboard) {
            try {
                var inJson = JSON.parse(AppFramework.clipboard.text);
                if (inJson.hasOwnProperty("latitude") && inJson.hasOwnProperty("longitude")) {
                    lat = inJson.latitude.toString().trim();
                    lon = inJson.longitude.toString().trim();
                }
            } catch(e) {
                if (e.toString().indexOf("JSON.parse: Parse error") > -1) {
                    var incoords = AppFramework.clipboard.text.split(',');
                    if (incoords.length === 2) {
                        lat = incoords[0].toString().trim();
                        lon = incoords[1].toString().trim();
                    }
                }
            } finally {
                if (lat !== "" && lon !== "") {
                    if (validateCoordinates(lat, lon)) {
                        clipboardDialog.clipLat = lat;
                        clipboardDialog.clipLon = lon;
                        clipboardDialog.open();

                        AppFramework.clipboard.clear();
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
}
