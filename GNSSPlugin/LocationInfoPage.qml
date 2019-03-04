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
import QtQuick.Controls 2.2

import ArcGIS.AppFramework 1.0

import "./controls"
import "XForm.js" as XFormJS

Page {
    id: page

    property PositionSourceManager positionSourceManager
    property var position: ({})

    property real timeOffset: positionSourceManager.timeOffset
    property var locale: app.locale // XXX this may be wrong

    property bool debug: false

    //--------------------------------------------------------------------------

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
            name: "horizontalAccuracy",
            label: qsTr("Horizontal accuracy"),
            valueTransformer: linearValue,
        },

        {
            name: "verticalAccuracy",
            label: qsTr("Vertical accuracy"),
            valueTransformer: linearValue,
        },
    ]

    //--------------------------------------------------------------------------

    title: qsTr("Location Status")

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager

        onNewPosition: {
            page.position = position;
        }
    }

    //--------------------------------------------------------------------------

    contentItem: ScrollView {
        id: container

        clip: true
        ScrollBar.vertical.policy: availableHeight < contentHeight
                                   ? ScrollBar.AlwaysOn
                                   : ScrollBar.AlwaysOff

        Column {
            width: container.width

            spacing: 10 * AppFramework.displayScaleFactor

            LocationCoordinateInfo {
                width: parent.width

                timeOffset: page.timeOffset
                position: page.position
                locale: page.locale
            }

            InfoView {
                width: parent.width

                model: kProperties

                dataDelegate: infoText
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: infoText

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
}
