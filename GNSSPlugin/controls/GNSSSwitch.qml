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

    Layout.preferredHeight: sf(50)
    Layout.preferredWidth: control.width
    Layout.fillWidth: true
    color: backgroundColor

    Switch {
        id: control

        y: parent.height / 2 - height / 2
        Layout.fillHeight: true
        Layout.fillWidth: true

        indicator: Rectangle {
            implicitWidth: sf(40)
            implicitHeight: sf(20)
            x: parent.x
            y: parent.height / 2 - height / 2
            radius: sf(10)
            border.width: sf(2)
            border.color: secondaryForegroundColor
            color: secondaryBackgroundColor
            opacity: enabled ? 1.0 : 0.3

            Rectangle {
                implicitWidth: sf(20)
                implicitHeight: sf(20)
                x: control.checked ? parent.width - width : 0
                y: parent.height / 2 - height / 2
                radius: sf(10)
                border.width: sf(1)
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
