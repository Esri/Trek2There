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

        debugButtonColor: buttonTextColor
        recordingColor: "red"
    }

    //--------------------------------------------------------------------------
}
