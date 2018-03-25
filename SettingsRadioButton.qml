import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

Rectangle {
    id: rect

    property alias text: textItem.text
    property alias checked: radioButton.checked

    Layout.preferredHeight: sf(50)
    Layout.fillWidth: true
    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
    Accessible.role: Accessible.Pane

    RadioButton{
        id: radioButton

        anchors.fill: parent
        Accessible.ignored: true

        indicator: Rectangle {
            implicitWidth: sf(20)
            implicitHeight: sf(20)
            x: sideMargin
            y: parent.height / 2 - height / 2
            radius: sf(10)
            border.width: sf(2)
            border.color: !nightMode ? "#595959" : nightModeSettings.foreground
            color: !nightMode ? "#ededed" : "#272727"
            Rectangle {
                anchors.fill: parent
                visible: parent.parent.checked
                color: !nightMode ? "#595959" : nightModeSettings.foreground
                radius: sf(9)
                anchors.margins: sf(4)
            }
        }
        contentItem: Text {
            id: textItem

            opacity: enabled ? 1.0 : 0.3
            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
            text: qsTr("RadioButton")
            verticalAlignment: Text.AlignVCenter
            leftPadding: radioButton.indicator.width + radioButton.spacing + sideMargin
        }
    }
}
