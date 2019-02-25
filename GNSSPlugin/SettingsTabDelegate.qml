import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0

import "./controls"

Rectangle {
    id: delegate

    property var listTabView

    property string fontFamily: Qt.application.font.family
    property color foregroundColor: "#000000"
    property color hoverBackgroundColor: "#e1f0fb"

    width: ListView.view.width
    height: visible ? rowLayout.height + rowLayout.anchors.margins * 2 : 0

    visible: modelData.enabled
    color: mouseArea.containsMouse ? hoverBackgroundColor : "transparent"

    RowLayout {
        id: rowLayout

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10 * AppFramework.displayScaleFactor
        }

        spacing: 10 * AppFramework.displayScaleFactor

        StyledImage {
            id: iconImage

            Layout.preferredWidth: 45 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: modelData.icon
            color: foregroundColor
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 3 * AppFramework.displayScaleFactor

            AppText {
                Layout.fillWidth: true

                text: modelData.title
                color: foregroundColor

                pointSize: 16
                fontFamily: delegate.fontFamily
                bold: true
            }

            AppText {
                Layout.fillWidth: true
                visible: text > ""

                text: modelData.description
                color: foregroundColor

                pointSize: 12
                fontFamily: delegate.fontFamily
                bold: false
            }
        }

        StyledImage {
            Layout.preferredWidth: 25 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: "images/next.png"
            color: foregroundColor
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            listTabView.selected(modelData);
        }
    }
}

