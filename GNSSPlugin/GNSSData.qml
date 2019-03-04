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
import ArcGIS.AppFramework.Positioning 1.0

import "XForm.js" as XFormJS
import "./controls"

SwipeTab {
    id: tab

    title: qsTr("Data")
    icon: "images/quality.png"

    //--------------------------------------------------------------------------

    property PositionSourceManager positionSourceManager
    property var position: ({})

    readonly property var controller: positionSourceManager.controller

    property real timeOffset: positionSourceManager.timeOffset
    property var locale: app.locale // XXX this may be wrong

    //--------------------------------------------------------------------------

    readonly property var kReceiver: [
        {
            name: "currentName",
            label: qsTr("Source"),
            source: controller,
        },

        {
            name: "fixType",
            label: qsTr("Mode"),
            valueTransformer: gpsModeText,
        },

        null,
    ]

    readonly property var kProperties: [
        null,

        {
            name: "speed",
            label: qsTr("Speed"),
            valueTransformer: speedValue,
        },

        {
            name: "verticalSpeed",
            label: qsTr("Vertical speed"),
            valueTransformer: speedValue,
        },

        null,

        {
            name: "direction",
            label: qsTr("Direction"),
            valueTransformer: angleValue,
        },

        {
            name: "magneticVariation",
            label: qsTr("Magnetic variation"),
            valueTransformer: angleValue,
        },

        null,

        {
            name: "accuracyType",
            label: qsTr("Accuracy mode"),
            valueTransformer: accuracyText,
        },

        {
            name: "horizontalAccuracy",
            label: qsTr("Horizontal accuracy"),
            valueTransformer: linearValue,
        },

        {
            name: "verticalAccuracy",
            label: qsTr("Vertical accuracy"),
            valueTransformer: linearValue,
        },

        {
            name: "positionAccuracy",
            label: qsTr("Position accuracy"),
            valueTransformer: linearValue,
        },

        null,

        {
            name: "hdop",
            label: qsTr("HDOP"),
        },

        {
            name: "vdop",
            label: qsTr("VDOP"),
        },

        {
            name: "pdop",
            label: qsTr("PDOP"),
        },

        null,

        {
            name: "latitudeError",
            label: qsTr("Latitude error"),
            valueTransformer: linearValue,
        },

        {
            name: "longitudeError",
            label: qsTr("Longitude error"),
            valueTransformer: linearValue,
        },

        {
            name: "altitudeError",
            label: qsTr("Altitude error"),
            valueTransformer: linearValue,
        },

        null,

        {
            name: "differentialAge",
            label: qsTr("Differential age"),
            valueTransformer: secondsValue,
        },

        {
            name: "referenceStationId",
            label: qsTr("Reference station id"),
        },

        {
            name: "geoidSeparation",
            label: qsTr("Geoid separation"),
            valueTransformer: linearValue,
        },
    ]

    //--------------------------------------------------------------------------

    ScrollView {
        id: container

        anchors {
            fill: parent
            margins: 10 * AppFramework.displayScaleFactor
        }

        clip: true
        ScrollBar.vertical.policy: availableHeight < contentHeight
                                   ? ScrollBar.AlwaysOn
                                   : ScrollBar.AlwaysOff

        Column {
            width: container.width

            spacing: 10 * AppFramework.displayScaleFactor

            InfoView {
                width: parent.width

                model: kReceiver

                dataDelegate: receiverText
            }

            LocationCoordinateInfo {
                width: parent.width

                timeOffset: tab.timeOffset
                position: tab.position
                locale: tab.locale
            }

            InfoView {
                width: parent.width

                model: kProperties

                dataDelegate: propertiesText
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: receiverText

        InfoDataText {
            label: kReceiver[modelIndex].label
            value: dataValue(kReceiver[modelIndex]);
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: propertiesText

        InfoDataText {
            label: kProperties[modelIndex].label
            value: dataValue(kProperties[modelIndex]);
        }
    }

    //--------------------------------------------------------------------------

    function dataValue(propertyInfo) {
        var source = propertyInfo.source;
        var valid = true;

        if (!source) {
            source = position;
            valid = source[propertyInfo.name + "Valid"];
        }

        var value = source[propertyInfo.name];

        if (!valid || value === undefined || value === null || (typeof value === "number" && !isFinite(value))) {
            return;
        }

        if (propertyInfo.valueTransformer) {
            return propertyInfo.valueTransformer(value);
        } else {
            return value;
        }
    }

    //--------------------------------------------------------------------------

    function linearValue(metres) {
        return XFormJS.toLocaleLengthString(metres, locale);
    }

    //--------------------------------------------------------------------------

    function speedValue(metresPerSecond) {
        return XFormJS.toLocaleSpeedString(metresPerSecond, locale);
    }

    //--------------------------------------------------------------------------

    function angleValue(degrees) {
        return "%1°".arg(degrees);
    }

    //--------------------------------------------------------------------------

    function secondsValue(seconds) {
        return qsTr("%1 s").arg(Math.round(seconds));
    }

    //--------------------------------------------------------------------------

    function gpsModeText(fixType) {
        switch (fixType) {
        case Position.NoFix:
            return qsTr("No Fix");

        case Position.GPS:
            return qsTr("GPS");

        case Position.DifferentialGPS:
            return qsTr("Differential GPS");

        case Position.PrecisePositioningService:
            return qsTr("Precise Positioning Service");

        case Position.RTKFixed:
            return qsTr("RTK Fixed");

        case Position.RTKFloat:
            return qsTr("RTK Float");

        case Position.Estimated:
            return qsTr("Estimated");

        case Position.Manual:
            return qsTr("Manual");

        case Position.Simulator:
            return qsTr("Simulator");

        case Position.Sbas:
            return qsTr("SBAS");

        default:
            return fixType;
        }
    }

    //--------------------------------------------------------------------------

    function accuracyText(accuracyType) {
        switch (accuracyType) {
        case Position.RMS:
            return qsTr("Error RMS");

        case Position.DOP:
            return qsTr("DOP Based");

        default:
            return accuracyType;
        }
    }

    //--------------------------------------------------------------------------
}
