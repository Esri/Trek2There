import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Speech 1.0

Rectangle {
    id: control

    property alias text: titleText.text

    property color foregroundColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
    property color backgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
    property color dividerColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

    property string fontFamily: Qt.application.font.family
    property real pointSize: 22
    property bool bold: false

    Layout.fillWidth: true
    Layout.preferredHeight: sf(50)

    color: backgroundColor

    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Navigation bar")

    ColumnLayout{
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                        color: backgroundColor
                        anchors.fill: parent
                    }

                    Image {
                        id: backArrow

                        source: "../images/back_arrow.png"
                        anchors.left: parent.left
                        anchors.leftMargin: sideMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - sf(15)
                        fillMode: Image.PreserveAspectFit
                        Accessible.ignored: true
                    }

                    ColorOverlay {
                        source: backArrow
                        anchors.fill: backArrow
                        color: foregroundColor
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

                color: backgroundColor

                Accessible.role: Accessible.Pane

                Text {
                    id: titleText

                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    font {
                        family: control.fontFamily
                        pointSize: control.pointSize
                        bold: control.bold
                    }

                    color: foregroundColor

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
                        color: backgroundColor
                        anchors.fill: parent
                    }

                    Image {
                        id: aboutIcon

                        source: "../images/about.png"
                        anchors.right: parent.right
                        anchors.rightMargin: sideMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - sf(25)
                        fillMode: Image.PreserveAspectFit
                        Accessible.ignored: true
                    }

                    ColorOverlay {
                        source: aboutIcon
                        anchors.fill: aboutIcon
                        color: foregroundColor
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1 * AppFramework.displayScaleFactor
            color: dividerColor

            Accessible.role: Accessible.Separator
            Accessible.ignored: true
        }
    }
}
