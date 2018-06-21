import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import "../GNSSPlugin"
import "../controls"

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Accessible.role: Accessible.Pane

        SettingsHeader {
            text: qsTr("Search external receiver")
        }

        ConnectionsPage {
            Layout.fillHeight: true
            Layout.fillWidth: true

            sources: app.sources
            controller: app.controller

            foregroundColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
            secondaryForegroundColor: !nightMode ? "#595959" : nightModeSettings.foreground
            backgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
            secondaryBackgroundColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
            connectedColor: buttonTextColor

            onIsConnectedChanged: {
                if (initialized && isConnected) {
                    mainStackView.pop();
                }
            }
        }
    }
}
