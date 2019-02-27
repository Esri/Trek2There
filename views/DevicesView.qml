import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import "../controls"
import "../GNSSPlugin"

Item {
    id: _item

    property StackView stackView
    property GNSSSettings gnssSettings
    property PositionSourceManager positionSourceManager
    readonly property PositioningSourcesController controller: positionSourceManager.controller

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Accessible.role: Accessible.Pane

        SettingsHeader {
            text: qsTr("Location Provider")
        }

        SettingsTabLocation {
            id: settingsTabLocation

            Layout.fillHeight: true
            Layout.fillWidth: true

            stackView: _item.stackView
            gnssSettings: _item.gnssSettings
            controller: _item.controller

            foregroundColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
            secondaryForegroundColor: buttonTextColor
            backgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
            secondaryBackgroundColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
            selectedBackgroundColor: !nightMode ? Qt.lighter(secondaryBackgroundColor) : Qt.darker(secondaryBackgroundColor)
            hoverBackgroundColor: buttonTextColor
            dividerColor: !nightMode ? "#c0c0c0" : Qt.darker("#c0c0c0")

            showDetailedSettingsCog: true // XXX only for testing, set to false for release
        }
    }
}
