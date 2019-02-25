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

//------------------------------------------------------------------------------

Rectangle {
    id: rectangle

    default property alias content: content.data
    property int padding: 5 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    implicitWidth: content.width + padding * 2
    implicitHeight: content.height + padding * 2

    radius: 5 * AppFramework.displayScaleFactor
    color: "#18000000"
    border {
        width: 1 * AppFramework.displayScaleFactor
        color: "#60ffffff"
    }

    //--------------------------------------------------------------------------

    Item {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: padding
        }

        height: childrenRect.height
    }

    //--------------------------------------------------------------------------
}
