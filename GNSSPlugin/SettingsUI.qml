import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

import "./controls"

Item {
    id: settingsUI

    property StackView stackView
    property GNSSSettings gnssSettings
    property PositionSourceManager positionSourceManager

    property alias title: locationSettingsTab.title

    property alias settingsTabContainer: settingsTabContainer
    property alias locationSettingsTab: locationSettingsTab

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

    signal showLocationSettings()

    //-------------------------------------------------------------------------

    onShowLocationSettings: {
        stackView.push(settingsTabContainer, {
                           settingsTab: locationSettingsTab,
                           title: locationSettingsTab.title,
                           settingsComponent: locationSettingsTab.contentComponent,
                       });
    }

    //-------------------------------------------------------------------------

    SettingsTabContainer {
        id: settingsTabContainer
    }

    //--------------------------------------------------------------------------

    SettingsTabLocation {
        id: locationSettingsTab

        Layout.fillHeight: true
        Layout.fillWidth: true

        title: qsTr("Location Provider")

        stackView: settingsUI.stackView
        gnssSettings: settingsUI.gnssSettings
        positionSourceManager: settingsUI.positionSourceManager

        foregroundColor: settingsUI.foregroundColor
        secondaryForegroundColor: settingsUI.secondaryForegroundColor
        backgroundColor: settingsUI.backgroundColor
        secondaryBackgroundColor: settingsUI.secondaryBackgroundColor
        hoverBackgroundColor: settingsUI.hoverBackgroundColor
        selectedBackgroundColor: settingsUI.selectedBackgroundColor
        dividerColor: settingsUI.dividerColor
        fontFamily: settingsUI.fontFamily

        showAboutDevice: settingsUI.showAboutDevice
        showAlerts: settingsUI.showAlerts
        showAntennaHeight: settingsUI.showAntennaHeight
        showAltitude: settingsUI.showAltitude
    }
}
