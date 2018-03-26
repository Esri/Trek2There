import QtQuick 2.8
import QtQml 2.2
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtPositioning 5.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

Rectangle {
    id: rect

    property alias label: label.text
    property alias text: destinationValue.text
    property alias placeholderText: destinationValue.placeholderText
    property alias validator: destinationValue.validator
    property bool invalid

    signal editingFinished()

    Layout.preferredHeight: sf(50)
    Layout.fillWidth: true
    Layout.bottomMargin: sf(2)
    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
    Accessible.role: Accessible.Pane

    onInvalidChanged: {
        if (invalid && !invalidAnimation.running) {
            invalidAnimation.start()
        }
    }

    PropertyAnimation {
        id: invalidAnimation

        target: rect
        property: "color"
        from: "red"
        to: !nightMode ? dayModeSettings.background : nightModeSettings.background
        duration: 1000
        easing.type: Easing.InCubic
        onStopped: invalid = false
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: sideMargin
        anchors.rightMargin: sideMargin
        spacing: 0
        Accessible.role: Accessible.Pane

        Text {
            id: label

            Layout.fillHeight: true
            Layout.preferredWidth: sf(120)
            verticalAlignment: Text.AlignVCenter
            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
            Accessible.role: Accessible.Heading
            Accessible.name: text
        }

        TextField {
            id: destinationValue

            Layout.fillHeight: true
            Layout.fillWidth: true
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle {
                anchors.fill: parent
                anchors.topMargin: sf(3)
                anchors.bottomMargin: sf(3)
                border.width: sf(0)
                border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
            }

            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground

            onEditingFinished: rect.editingFinished();
        }
    }
}
