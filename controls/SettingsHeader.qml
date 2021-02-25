import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

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
    property real pixelSize: 22 * AppFramework.displayScaleFactor
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
                        anchors.fill: parent
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
                        pixelSize: control.pixelSize
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
                        anchors.fill: parent
                        anchors.margins: sf(10)
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
