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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

TextField {
    id: text

    property string fontFamily: Qt.application.font.family
    property real pointSize: 15
    property bool bold: false

    //--------------------------------------------------------------------------

    style: TextFieldStyle {
        renderType: Text.QtRendering
        textColor: "black"
        font {
            family: text.fontFamily
            pointSize: text.pointSize
            bold: text.bold
        }
    }

    //--------------------------------------------------------------------------
}
