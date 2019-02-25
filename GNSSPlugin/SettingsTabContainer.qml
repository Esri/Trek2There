import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0

import "./controls"

Component {
    id: settingsTabContainer

    Page {
        property Item settingsTab

        property alias settingsComponent: loader.sourceComponent
        property alias settingsItem: loader.item

        signal loaderComplete();

        textColor: locationSettingsTab.foregroundColor
        headerBarColor: locationSettingsTab.backgroundColor
        backgroundColor: locationSettingsTab.secondaryBackgroundColor

        contentMargins: 0

        contentItem: Loader {
            id: loader
        }

        Component.onDestruction: {
            saveSettings();
        }

        onTitlePressAndHold: {
            settingsTab.titlePressAndHold();
        }

        //--------------------------------------------------------------------------

        function saveSettings() {
            locationSettingsTab.gnssSettings.write();
        }

        //--------------------------------------------------------------------------
    }
}
