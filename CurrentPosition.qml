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

import QtQuick 2.8
import QtPositioning 5.8
import QtLocation 5.8

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

//------------------------------------------------------------------------------

QtObject {
    id: currentPosition

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool usingCompass

    property var destinationCoordinate
    property var positionCoordinate
    property var position
    property var compassAzimuth

    property double distanceToDestination: NaN
    property double azimuthToDestination: NaN
    property double degreesOffCourse: NaN

    property bool useKalman
    property double kalmanLat
    property double kalmanLong
    property KalmanCoordinate kalmanCoord: KalmanCoordinate {}

    // not used at present
    property double etaSeconds: NaN

    property int minimumArrivalTimeInSeconds: 3 // seconds
    property double minimumAnticipatedSpeed: 1.4 // m/s
    property double maximumAnticipatedSpeed: 28 // m/s

    property int arrivalThresholdInMeters: position.horizontalAccuracyValid && position.horizontalAccuracy < 20 ? position.horizontalAccuracy : 20
    property int arrivalThresholdInSeconds: minimumArrivalTimeInSeconds

    signal atDestination()

    //--------------------------------------------------------------------------

    onPositionChanged: {
        if (position.coordinate.isValid) {
            calculate();
        }
    }

    //--------------------------------------------------------------------------

    onAtDestination: {
        kalmanCoord.reset();
    }

    //--------------------------------------------------------------------------

    function clearData() {
        distanceToDestination = NaN;
        azimuthToDestination = NaN;
        degreesOffCourse = NaN;
        kalmanCoord.reset();
    }

    //--------------------------------------------------------------------------

    function calculate() {

        positionCoordinate = position.coordinate;

        if (useKalman) {
            var accuracy = (position.horizontalAccuracyValid === true) ? position.horizontalAccuracy : 0;
            var newCoord = kalmanCoord.process(positionCoordinate.latitude, positionCoordinate.longitude, accuracy, new Date().valueOf());
            kalmanLat = newCoord[0];
            kalmanLong = newCoord[1]
            positionCoordinate = QtPositioning.coordinate(kalmanLat,kalmanLong);
        }

        distanceToDestination = positionCoordinate.distanceTo(destinationCoordinate);
        azimuthToDestination = positionCoordinate.azimuthTo(destinationCoordinate);

        if (usingCompass) {
            degreesOffCourse = azimuthToDestination - compassAzimuth;
        } else {
            if (position.directionValid) {
                degreesOffCourse = azimuthToDestination - position.direction;
            } else {
                degreesOffCourse = NaN;
            }
        }

        if (distanceToDestination < arrivalThresholdInMeters ) {
            atDestination();
        }

        // XXX this needs thinking about
        if (position.speedValid && position.speed > minimumAnticipatedSpeed) {
            etaSeconds = distanceToDestination / position.speed;
            arrivalThresholdInSeconds = minimumArrivalTimeInSeconds * (position.speed / minimumAnticipatedSpeed);
             if (etaSeconds < arrivalThresholdInSeconds) {
                atDestination();
            }
        }

        if (logTreks) {
            // [timestamp, pos_lat, pos_long, pos_dir, klat, klong, az_to, dist_to, degrees_off]
            trekLogger.recordPosition([
                                          Date().valueOf(),
                                          positionCoordinate.latitude.toString(),
                                          positionCoordinate.longitude.toString(),
                                          ( (position.directionValid) ? position.direction.toString() : "invalid direction" ),
                                          ( (useKalman) ? kalmanLat.toString() : "kalman turned off" ),
                                          ( (useKalman) ? kalmanLong.toString() : "kalman turned off" ),
                                          azimuthToDestination.toString(),
                                          distanceToDestination.toString(),
                                          degreesOffCourse.toString()
                                      ]);
        }
    }
}
