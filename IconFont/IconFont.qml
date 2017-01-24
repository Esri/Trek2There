/* Copyright 2017 Esri
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

import QtQuick 2.0

FontLoader{

    // ttf font file created with fontastic.me

    source: "fonts/trek2there.ttf"

    property string accuracy1: "1"
    property string accuracy2: "2"
    property string accuracy3: "3"
    property string accuracy4: "4"
    property string accuracy5: "5"
    property string accuracy_indicator: "b"

    property string settings: "a"
    property string swap: "c"

    //--------------------------------------------------------------------------

    function getIconByName(name){
        return this[name];
    }

}
