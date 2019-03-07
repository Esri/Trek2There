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

import QtQml 2.2
import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0

import "../GNSS"
import "../controls"

SwipeTab {
    id: tab

    title: qsTr("Debug")
    icon: "../images/debug.png"

    color: "black"

    //--------------------------------------------------------------------------

    property PositionSourceManager positionSourceManager
    property NmeaSource nmeaSource: positionSourceManager.nmeaSource

    //--------------------------------------------------------------------------

    property bool isPaused: false

    property string fontFamily

    property color buttonColor: "lightgrey"
    property color validDataColor: "#00ff00"
    property color invalidDataColor: "#A80000"

    property bool debug: false

    //--------------------------------------------------------------------------

    signal clear()

    //--------------------------------------------------------------------------

    onClear: {
        dataModel.clear();
    }

    //--------------------------------------------------------------------------

    Connections {
        target: nmeaSource

        onReceivedNmeaData: {
            if (!isPaused) {
                var nmea = nmeaSource.receivedSentence.trim();

                if (debug) {
                    console.log("nmea:", nmea);
                }

                dataModel.append({
                                     dataText: nmea,
                                     isValid: true
                                 });
            }

            if (dataModel.count > 100) {
                dataModel.remove(0);
            }
        }
    }

    //--------------------------------------------------------------------------

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5 * AppFramework.displayScaleFactor

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3 * AppFramework.displayScaleFactor
            clip: true

            model: dataModel
            delegate: dataDelegate
        }
    }

    //--------------------------------------------------------------------------

    ListModel {
        id: dataModel

        onCountChanged: {
            if (count > 0) {
                listView.positionViewAtEnd();
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: dataDelegate

        Text {
            width: ListView.view.width

            text: dataText
            color: isValid ? validDataColor : invalidDataColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            font {
                pointSize: 12
                family: fontFamily
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.bottom
                }

                height: 1
                color: "#80808080"
            }
        }
    }

    //--------------------------------------------------------------------------

    RowLayout {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 15 * AppFramework.displayScaleFactor
        }

        StyledImageButton {
            Layout.preferredWidth: 40 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: isPaused ? "../images/play.png" : "../images/pause.png"
            color: buttonColor

            onClicked: {
                isPaused = !isPaused;
            }
        }

        StyledImageButton {
            Layout.preferredWidth: 40 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: "../images/clear.png"
            color: buttonColor
            visible: dataModel.count > 0

            onClicked: {
                clear();
            }
        }
    }

    //--------------------------------------------------------------------------
}

