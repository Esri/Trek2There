import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

Rectangle {
    property alias control: control
    property alias checked: control.checked
    property alias text: textItem.text

    property color foregroundColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
    property color secondaryForegroundColor: !nightMode ? "#595959" : nightModeSettings.foreground
    property color backgroundColor: !nightMode ? dayModeSettings.background : nightModeSettings.background
    property color secondaryBackgroundColor: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

    readonly property double scaleFactor: AppFramework.displayScaleFactor

    Layout.preferredHeight: 50 * scaleFactor
    Layout.preferredWidth: control.width
    Layout.fillWidth: true
    color: backgroundColor

    Switch {
        id: control

        y: parent.height / 2 - height / 2
        Layout.fillHeight: true
        Layout.fillWidth: true

        indicator: Rectangle {
            implicitWidth: 40 * scaleFactor
            implicitHeight: 20 * scaleFactor
            x: parent.x
            y: parent.height / 2 - height / 2
            radius: 10 * scaleFactor
            border.width: 2 * scaleFactor
            border.color: secondaryForegroundColor
            color: secondaryBackgroundColor
            opacity: enabled ? 1.0 : 0.3

            Rectangle {
                implicitWidth: 20 * scaleFactor
                implicitHeight: 20 * scaleFactor
                x: control.checked ? parent.width - width : 0
                y: parent.height / 2 - height / 2
                radius: 10 * scaleFactor
                border.width: 1 * scaleFactor
                border.color: secondaryForegroundColor
                color: secondaryForegroundColor
            }
        }

        contentItem: Text {
            id: textItem

            opacity: enabled ? 1.0 : 0.3
            color: foregroundColor

            text: qsTr("Switch")
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
        }
    }
}
