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

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Speech 1.0
import ArcGIS.AppFramework.Notifications 1.0

import "./controls"

Item {

    property bool dimDisplay: false

    property color infoTextColor: "white"
    property color infoBackgroundColor: "blue"

    property color warningTextColor: "black"
    property color warningBackgroundColor: "#FFBF00"

    property color errorTextColor: "white"
    property color errorBackgroundColor: "#a80000"

    readonly property url kIconSatellite: "./images/satellite.png"

    //--------------------------------------------------------------------------

    anchors {
        fill: parent
    }

    //--------------------------------------------------------------------------

    readonly property var kPositionAlertInfos: [
        {
            type: 1,
            sayMessage: qsTr("The location sensor is connected"),
            icon: kIconSatellite,
            displayMessage: qsTr("Location sensor connected"),
            textColor: infoTextColor,
            backgroundColor: infoBackgroundColor,
        },

        {
            type: 2,
            sayMessage: qsTr("The location sensor is disconnected"),
            icon: kIconSatellite,
            displayMessage: qsTr("Location sensor disconnected"),
            textColor: errorTextColor,
            backgroundColor: errorBackgroundColor,
        },

        {
            type: 3,
            sayMessage: qsTr("No data is being received from the location sensor"),
            icon: kIconSatellite,
            displayMessage: qsTr("No data received"),
            textColor: warningTextColor,
            backgroundColor: warningBackgroundColor,
        },

        {
            type: 4,
            sayMessage: qsTr("No positions are being received from the location sensor"),
            icon: kIconSatellite,
            displayMessage: qsTr("No position received"),
            textColor: warningTextColor,
            backgroundColor: warningBackgroundColor,
        }
    ]

    //--------------------------------------------------------------------------

    z: 99999

    //--------------------------------------------------------------------------

    function positionSourceAlert(alertType) {
        console.log("positionSourceAlert:", alertType);

        var alertInfo;

        for (var i = 0; i < kPositionAlertInfos.length; i++) {
            if (kPositionAlertInfos[i].type === alertType) {
                alertInfo = kPositionAlertInfos[i];
                break;
            }
        }

        var sayMessage;
        var icon;
        var displayMessage;
        var textColor;
        var backgroundColor;

        if (alertInfo) {
            sayMessage = alertInfo.sayMessage;
            icon = alertInfo.icon;
            displayMessage = alertInfo.displayMessage;
            textColor = alertInfo.textColor;
            backgroundColor = alertInfo.backgroundColor;
        } else {
            sayMessage = qsTr("Position source alert %1").arg(alertType);
            icon = kIconSatellite;
            displayMessage = qsTr("Position source alert %1").arg(alertType);
            textColor = warningTextColor;
            backgroundColor = warningBackgroundColor;
        }

        if (gnssSettings.locationAlertsVibrate) {
            Vibration.vibrate();
        }

        if (gnssSettings.locationAlertsSpeech) {
            say(sayMessage);
        }

        if (gnssSettings.locationAlertsVisual) {
            show(displayMessage, icon, textColor, backgroundColor);
        }
    }

    //--------------------------------------------------------------------------

    function say(message, priority) {
        if (tts.state !== TextToSpeech.Ready && !priority) {
            return;
        }

        if (tts.state === TextToSpeech.Speaking) {
            tts.stop();
        }

        tts.say(message);
    }

    //--------------------------------------------------------------------------

    function show(message, icon, textColor, backgroundColor, duration, priority) {
        if (faderMessage.visible && !priority) {
            return;
        }

        if (textColor === undefined) {
            textColor = infoTextColor;
        }

        if (backgroundColor === undefined) {
            backgroundColor = infoBackgroundColor;
        }

        faderMessage.show(message, icon, textColor, backgroundColor, duration);
    }

    //--------------------------------------------------------------------------

    TextToSpeech {
        id: tts
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        visible: faderMessage.visible && dimDisplay
        color: "#30000000"
    }

    FaderMessage {
        id: faderMessage
    }

    MouseArea {
        anchors.fill: parent

        enabled: faderMessage.visible

        onClicked: {
            faderMessage.hide();

            if (tts.state === TextToSpeech.Speaking) {
                tts.stop();
            }
        }
    }

    //--------------------------------------------------------------------------
}
