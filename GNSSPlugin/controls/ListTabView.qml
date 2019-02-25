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
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

Item {
    default property alias contentData: container.data

    property alias tabViewContainer: container
    property alias delegate: listTabViewListView.delegate

    //--------------------------------------------------------------------------

    signal selected(Item item)

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        console.log("# ListTab items:", container.children.length);
    }

    //--------------------------------------------------------------------------

    ScrollView {
        anchors.fill: parent

        ListView {
            id: listTabViewListView

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            model: container.children
        }
    }

    //--------------------------------------------------------------------------

    Item {
        id: container
    }

    //--------------------------------------------------------------------------
}
