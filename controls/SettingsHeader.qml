import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Speech 1.0

Rectangle {
    property alias text: titleText.text

    Layout.fillWidth: true
    Layout.preferredHeight: sf(50)

    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Navigation bar")

    RowLayout {
        anchors.fill: parent
        spacing: 0
        Accessible.role: Accessible.Pane

        Rectangle {
            id: backButtonContainer
            Layout.fillHeight: true
            Layout.preferredWidth: sf(50)
            Accessible.role: Accessible.Pane

            Button {
                anchors.fill: parent
                background: Rectangle {
                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                    anchors.fill: parent
                }
                Image {
                    id: backArrow
                    source: "../images/back_arrow.png"
                    anchors.left: parent.left
                    anchors.leftMargin: sideMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - sf(30)
                    fillMode: Image.PreserveAspectFit
                    Accessible.ignored: true
                }
                ColorOverlay {
                    source: backArrow
                    anchors.fill: backArrow
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    Accessible.ignored: true
                }

                onClicked: {
                    Qt.inputMethod.hide();

                    mainStackView.pop();
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Go back")
                Accessible.description: qsTr("Go back to previous view")
                Accessible.onPressAction: {
                    clicked();
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
            Accessible.role: Accessible.Pane

            Text {
                id: titleText

                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Title")
                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                Accessible.role: Accessible.Heading
                Accessible.name: text
            }
        }

        Rectangle {
            id: aboutButtonContainer
            Layout.fillHeight: true
            Layout.preferredWidth: sf(50)
            Accessible.role: Accessible.Pane

            Button {
                anchors.fill: parent
                background: Rectangle {
                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                    anchors.fill: parent
                }
                Image {
                    id: aboutIcon
                    source: "../images/about.png"
                    anchors.left: parent.left
                    anchors.leftMargin: sideMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - sf(30)
                    fillMode: Image.PreserveAspectFit
                    Accessible.ignored: true
                }
                ColorOverlay {
                    source: aboutIcon
                    anchors.fill: aboutIcon
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    Accessible.ignored: true
                }

                onClicked: {
                    mainStackView.push(aboutView);
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("About the app")
                Accessible.description: qsTr("This button will take you to the About view.")
                Accessible.onPressAction: {
                    clicked();
                }
            }
        }
    }
}
