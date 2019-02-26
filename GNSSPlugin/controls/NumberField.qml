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

import ArcGIS.AppFramework 1.0

RowLayout {
    property alias prefixText: prefixText.text
    property alias suffixText: suffixText.text
    property alias placeholderText: textField.placeholderText

    property real value: Number.NaN

    //--------------------------------------------------------------------------

    AppText {
        id: prefixText

        visible: text > ""
        color: foregroundColor
    }

    AppTextField {
        id: textField

        Layout.fillWidth: true

        text: isFinite(value) ? value : ""
        color: foregroundColor

        Component.onCompleted: {
            if (Qt.platform.os === "ios") {
                inputMethodHints = Qt.ImhPreferNumbers;
            } else {
                inputMethodHints = Qt.ImhDigitsOnly ;
            }
        }

        onTextChanged: {
            updateValue();
        }

        onEditingFinished: {
            updateValue();
        }

        function updateValue() {
            if (length && acceptableInput) {
                value = Number(text);
            } else {
                value = Number.NaN;
            }
        }
    }

    AppText {
        id: suffixText

        visible: text > ""
        color: foregroundColor
    }

    //--------------------------------------------------------------------------
}
