/* Copyright 2021 Esri
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

import QtQuick 2.15
import QtPositioning 5.15
import QtLocation 5.15

import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

QtObject {
    id: currentPosition

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool navigating
    property bool usingCompass

    property var position
    property var destinationCoordinate
    property double compassAzimuth

    property double distanceToDestination: NaN
    property double azimuthToDestination: NaN
    property double degreesOffCourse: NaN
    property double etaSeconds: NaN

    property bool useKalman
    property double kalmanLat
    property double kalmanLong
    property KalmanCoordinate kalmanCoord: KalmanCoordinate {}

    property int arrivalThresholdInMeters: position && position.horizontalAccuracyValid && position.horizontalAccuracy < 10 ? position.horizontalAccuracy : 10
    property int arrivalThresholdInSeconds: 30

    signal navigatingToDestination()
    signal soonAtDestination()
    signal atDestination()
    signal updateUI()

    //--------------------------------------------------------------------------

    onPositionChanged: {
        if (navigating && destinationCoordinate && destinationCoordinate.isValid && position && position.coordinate.isValid) {
            calculate();
        } else {
            updateUI();
        }
    }

    //--------------------------------------------------------------------------

    onCompassAzimuthChanged: {
        if (usingCompass) {
            if (navigating && destinationCoordinate && destinationCoordinate.isValid && position && position.coordinate.isValid) {
                calculate();
            } else {
                updateUI();
            }
        }
    }

    //--------------------------------------------------------------------------

    onNavigatingChanged: {
        if (navigating) {
            clearData();
        }
    }

    //--------------------------------------------------------------------------

    function clearData() {
        distanceToDestination = NaN;
        azimuthToDestination = NaN;
        degreesOffCourse = NaN;
        etaSeconds = NaN;
        kalmanCoord.reset();
    }

    //--------------------------------------------------------------------------

    function calculate() {
        var positionCoordinate = position.coordinate;

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
        } else if (position.directionValid) {
            degreesOffCourse = azimuthToDestination - position.direction;
        } else {
            degreesOffCourse = NaN;
        }

        if (distanceToDestination < arrivalThresholdInMeters ) {
            atDestination();
        } else if (position.speedValid && position.speed > maximumSpeedForCompass) {
            etaSeconds = distanceToDestination / position.speed;
            if (etaSeconds <= arrivalThresholdInSeconds) {
                soonAtDestination();
            } else {
                navigatingToDestination();
            }
        } else {
            navigatingToDestination();
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
