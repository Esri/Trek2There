/* Copyright 2018 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    id: page

    property Item contentItem

    property alias title: titleText.text

    property color textColor: "#000000"
    property color headerBarColor: "#c0c0c0"
    property color backgroundColor: "#f8f8f8"

    property string fontFamily: Qt.application.font.family
    property real pointSize: 22
    property bool bold: false

    property real headerBarHeight: 50 * AppFramework.displayScaleFactor
    property real contentMargins: 15 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    signal titleClicked()
    signal titlePressAndHold()

    //--------------------------------------------------------------------------

    color: backgroundColor

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        if (contentItem) {
            contentItem.parent = page;
            contentItem.anchors.left = page.left;
            contentItem.anchors.right = page.right;
            contentItem.anchors.top = headerBar.bottom;
            contentItem.anchors.bottom = page.bottom;
            contentItem.anchors.margins = contentMargins;
        }
    }

    QtObject {
        id: internal

        property real buttonSize: 40 * AppFramework.displayScaleFactor
    }

    Rectangle {
        id: headerBar

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: headerBarHeight
        color: headerBarColor

        MouseArea {
            anchors.fill: parent

            onClicked: {
                titleClicked();
            }

            onPressAndHold: {
                titlePressAndHold();
            }
        }

        RowLayout {
            anchors.fill: parent

            Item {
                Layout.preferredWidth: internal.buttonSize
                Layout.preferredHeight: internal.buttonSize
                Layout.alignment: Qt.AlignVCenter

                height: width

                StyledImageButton {
                    id: backButton

                    anchors {
                        fill: parent
                        margins: 2
                    }

                    source: "../images/back.png"
                    color: textColor

                    onClicked: {
                        closePage();
                    }
                }
            }

            AppText {
                id: titleText

                Layout.fillWidth: true
                Layout.fillHeight: true

                color: textColor

                pointSize: page.pointSize
                fontFamily: page.fontFamily
                bold: page.bold

                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Item {
                Layout.preferredWidth: internal.buttonSize
                Layout.preferredHeight: internal.buttonSize
            }
        }
    }

    //--------------------------------------------------------------------------

    function closePage() {
        page.parent.pop();
    }

    //--------------------------------------------------------------------------
}
