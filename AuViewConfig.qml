import QtQuick 2.5
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0

Item {
    id: config

    property Settings settings

    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property real kNearMaxDist: 1000
    readonly property real kFarMaxDist: 10000
    readonly property real kLowerMaxHeight: 10
    readonly property real kUpperMaxHeight: 100

    //--------------------------------------------------------------------------

    readonly property real kDefaultHorizontalAccuracyThreshold: 10
    readonly property real kDefaultVerticalAccuracyThreshold: 10

    readonly property real kDefaultCompassCalibrationThreshold: 0.5

    //--------------------------------------------------------------------------

    readonly property string kPrefixLastLocation: "lastLocation/"
    readonly property string kSettingLatitude: kPrefixLastLocation + "latitude"
    readonly property string kSettingLongitude: kPrefixLastLocation + "longitude"
    readonly property string kSettingAltitude: kPrefixLastLocation + "altitude"

    readonly property string kSettingShowInfo: "showInfo"
    readonly property string kSettingShowHorizon: "showHorizon"
    readonly property string kSettingShowCompass: "showCompass"
    readonly property string kSettingShowPopups: "showPopups"
    readonly property string kSettingShowVideoEffects: "showVideoEffects"

    readonly property string kSettingManualPitch: "manualPitch"
    readonly property string kSettingManualRoll: "manualRoll"
    readonly property string kSettingManualCompass: "manualCompass"

    readonly property string kSettingUseRotationZAsAzimuth: "useRotationZAsAzimuth"
    readonly property string kSettingUsePositionSourceAltitude: "usePositionSourceAltitude"

    readonly property string kSettingLocationMode: "locationMode"
    readonly property string kSettingMapType: "mapType"
    readonly property string kSettingGridType: "gridType"
    readonly property string kSettingOverviewMapStyle: "overviewMapStyle"
    readonly property string kSettingOverviewMapType: "overviewMapType"

    readonly property string kSettingMaximumDistance: "maximumDistance"
    readonly property string kSettingMagneticDeclination: "magneticDeclination"
    readonly property string kSettingFixedAltitude: "fixedAltitude"
    readonly property string kSettingDeviceHeight: "deviceHeight"
    readonly property string kSettingLocationThreshold: "locationThreshold"
    readonly property string kSettingPositionSourceOffsetX: "positionSourceOffsetX"
    readonly property string kSettingPositionSourceOffsetY: "positionSourceOffsetY"
    readonly property string kSettingPositionSourceOffsetZ: "positionSourceOffsetZ"
    readonly property string kSettingHorizontalAccuracyThreshold: "horizontalAccuracyThreshold"
    readonly property string kSettingVerticalAccuracyThreshold: "verticalAccuracyThreshold"

    readonly property string kSettingFieldOfViewX: "fieldOfViewX"
    readonly property string kSettingFieldOfViewY: "fieldOfViewY"

    readonly property string kSettingAzimuthFilterType: "azimuthFilterType"
    readonly property string kSettingAzimuthRounding: "azimuthRounding"
    readonly property string kSettingAzimuthFilterLength: "azimuthFilterLength"

    readonly property string kSettingAttitudeFilterType: "attitudeFilterType"
    readonly property string kSettingAttitudeRounding: "attitudeRounding"
    readonly property string kSettingAttitudeFilterLength: "attitudeFilterLength"

    readonly property string kSettingCompassCalibrationThreshold: "compassCalibrationThreshold"

    readonly property string kSettingDataSourceId: "dataSourceId"

    readonly property string kSettingPopupMinimumScale: "popupMinimumScale"
    readonly property string kSettingPopupMaximumScale: "popupMaximumScale"
    readonly property string kSettingPopupOpacity: "popupOpacity"

    readonly property string kSettingPopupDefaultPrefix: "default"
    readonly property string kSettingPopupSelectedPrefix: "selected"

    readonly property var popupStyleSets: [kSettingPopupDefaultPrefix, kSettingPopupSelectedPrefix]
    readonly property var popupStyleOptions: ["Title", "Contents", "Media", "Distance"]

    property bool showHorizon: true
    property bool showCompass: true
    property bool showPopups: true
    property bool showInfo: false
    property bool showVideoEffects: false

    property bool manualPitch: false
    property bool manualRoll: false
    property bool manualCompass: false

    property bool useRotationZAsAzimuth: isAndroid
    property bool usePositionSourceAltitude: false

    property int locationMode: 1 // 0=Manual, 1=PositionSource
    property int mapType: 0
    property int gridType: 1 // 0=None 1=circular 2=rectangular, fixed to bearing, 3=rectangular, fixed to north
    property int overviewMapStyle: 1 // 0=None 1=180° 2=360° 3=360° North Up
    property int overviewMapType: 6
    property real overviewMapSize: 1.2

    property real maximumDistance: 1000.0
    property real magneticDeclination: 0.0
    property real fixedAltitude: 0.0
    property real deviceHeight: 1.6
    property real locationThreshold: 3.0
    property real positionSourceOffsetX: 0.0
    property real positionSourceOffsetY: 0.0
    property real positionSourceOffsetZ: 0.0
    property real horizontalAccuracyThreshold: kDefaultHorizontalAccuracyThreshold
    property real verticalAccuracyThreshold: kDefaultVerticalAccuracyThreshold

    property real cameraFieldOfViewX: 48
    property real cameraFieldOfViewY: 61
    property real fieldOfViewX: cameraFieldOfViewX
    property real fieldOfViewY: cameraFieldOfViewY

    property int azimuthFilterType: isAndroid ? 1 : 0 // 0=rounding 1=smoothing
    property int azimuthRounding: 2
    property int azimuthFilterLength: 10

    property int attitudeFilterType: isAndroid ? 1 : 0 // 0=rounding 1=smoothing
    property int attitudeRounding: 2
    property int attitudeFilterLength: 10

    property real compassCalibrationThreshold: kDefaultCompassCalibrationThreshold

    property real popupMinimumScale: 0.5
    property real popupMaximumScale: 1.0
    property real popupOpacity: 0.8

    property bool defaultPopupTitle: true
    property bool defaultPopupContents: false
    property bool defaultPopupMedia: false
    property bool defaultPopupDistance: true

    property bool selectedPopupTitle: true
    property bool selectedPopupContents: true
    property bool selectedPopupMedia: true
    property bool selectedPopupDistance: true

    property string dataSourceId
    property string cameraDeviceId

    property bool showCanvas2D: true
    property bool showCanvas3D: false

    property color optionsColor: "white"
    property color compassColor: "#00b2ff"
    property color locationColor: "#00b2ff"
    property color infoPanelColor: "#00FF00"
    property color fieldOfViewColor: "red"
    property color labelBackgroundColor: "#60000000"
    property color labelTextColor: "white"

    property color kCalibrationLevelColor1: "red"
    property color kCalibrationLevelColor2: "#ffbf00"
    property color kCalibrationLevelColor3: "green"

    property var kCalibrationLevelColors: [
        kCalibrationLevelColor1,
        kCalibrationLevelColor2,
        kCalibrationLevelColor3
    ]

    property var kCalibrationLevelLabels: [
        qsTr("unreliable"),
        qsTr("approximate"),
        qsTr("high")
    ]

    //--------------------------------------------------------------------------

    function updateCameraSettings() {
        if (Qt.platform.os === "ios") {
            // iPhone 6, aspect ratio is slightly < 4/3
            cameraFieldOfViewX = 48;
            cameraFieldOfViewY = 61;
        } else if (Qt.platform.os === "android") {
            // Samsung Galaxy S7, aspect ratio is 4/3
            cameraFieldOfViewX = 50.22;
            cameraFieldOfViewY = 64.0;
        } else if (Qt.platform.os === "windows") {
            // Surface Book, aspect ratio is 16/9
            cameraFieldOfViewX = 61.0;
            cameraFieldOfViewY = 36.66;
        } else {
            // MacBook Pro, aspect ratio is 16/9
            cameraFieldOfViewX = 90;
            cameraFieldOfViewY = 59;
        }

        console.log("Updating camera settings, FoVX", cameraFieldOfViewX, "FoVY", cameraFieldOfViewY, "platform", Qt.platform.os);
    }
    //--------------------------------------------------------------------------

    function popupStyleKey(set, name) {
        return "%1Popup%2".arg(set).arg(name);
    }

    //--------------------------------------------------------------------------

    function readLocation() {
        var latitude = settings.numberValue(kSettingLatitude, -37.83066);
        var longitude = settings.numberValue(kSettingLongitude, 144.96561);
        var altitude = settings.numberValue(kSettingAltitude, 0);

        var coordinate = QtPositioning.coordinate(latitude, longitude, altitude);

        console.log("Read location:", coordinate);

        return coordinate;
    }

    function read() {
        // must be first!
        updateCameraSettings();

        console.log("Reading config:");

        showHorizon = settings.boolValue(kSettingShowHorizon, true);
        showCompass = settings.boolValue(kSettingShowCompass, true);
        showPopups = settings.boolValue(kSettingShowPopups, true);
        showInfo = settings.boolValue(kSettingShowInfo, false);
        showVideoEffects = settings.boolValue(kSettingShowVideoEffects, false);

        manualPitch = settings.boolValue(kSettingManualPitch, false);
        manualRoll = settings.boolValue(kSettingManualRoll, false);
        manualCompass = settings.boolValue(kSettingManualCompass, false);

        useRotationZAsAzimuth = settings.boolValue(kSettingUseRotationZAsAzimuth, isAndroid);
        usePositionSourceAltitude = settings.boolValue(kSettingUsePositionSourceAltitude, false);

        locationMode = settings.numberValue(kSettingLocationMode, 1);
        mapType = settings.numberValue(kSettingMapType, 0);
        gridType = settings.numberValue(kSettingGridType, 1);
        overviewMapStyle = settings.numberValue(kSettingOverviewMapStyle, 1);
        overviewMapType = settings.numberValue(kSettingOverviewMapType, 6);

        maximumDistance = settings.value(kSettingMaximumDistance, 1000);
        magneticDeclination = settings.numberValue(kSettingMagneticDeclination, 0);
        fixedAltitude = settings.numberValue(kSettingFixedAltitude, 0);
        deviceHeight = settings.value(kSettingDeviceHeight, 1.6);
        locationThreshold = settings.numberValue(kSettingLocationThreshold, 3);
        positionSourceOffsetX = settings.numberValue(kSettingPositionSourceOffsetX, 0);
        positionSourceOffsetY = settings.numberValue(kSettingPositionSourceOffsetY, 0);
        positionSourceOffsetZ = settings.numberValue(kSettingPositionSourceOffsetZ, 0);
        horizontalAccuracyThreshold = settings.numberValue(kSettingHorizontalAccuracyThreshold, kDefaultHorizontalAccuracyThreshold);
        verticalAccuracyThreshold = settings.numberValue(kSettingVerticalAccuracyThreshold, kDefaultVerticalAccuracyThreshold);

        fieldOfViewX = settings.value(kSettingFieldOfViewX, cameraFieldOfViewX);
        fieldOfViewY = settings.value(kSettingFieldOfViewY, cameraFieldOfViewY);

        azimuthFilterType = settings.numberValue(kSettingAzimuthFilterType, isAndroid ? 1 : 0);
        azimuthRounding = settings.numberValue(kSettingAzimuthRounding, 2);
        azimuthFilterLength = settings.value(kSettingAzimuthFilterLength, 10);

        attitudeFilterType = settings.numberValue(kSettingAttitudeFilterType, isAndroid ? 1 : 0);
        attitudeRounding = settings.numberValue(kSettingAttitudeRounding, 2);
        attitudeFilterLength = settings.value(kSettingAttitudeFilterLength, 10);

        compassCalibrationThreshold = settings.numberValue(kSettingCompassCalibrationThreshold, kDefaultCompassCalibrationThreshold);

        dataSourceId = settings.value(kSettingDataSourceId, "");

        popupMinimumScale = settings.numberValue(kSettingPopupMinimumScale, 0.5);
        popupMaximumScale = settings.numberValue(kSettingPopupMaximumScale, 1);
        popupOpacity = settings.numberValue(kSettingPopupOpacity, 0.8);

        popupStyleSets.forEach(function(set) {
            popupStyleOptions.forEach(function(name) {
                var settingKey = popupStyleKey(set, name)
                config[settingKey] = settings.boolValue(settingKey, config[settingKey]);
                console.log(settingKey, config[settingKey]);
            });
        });

        log();
    }

    //--------------------------------------------------------------------------

    function saveLocation(observerCoordinate) {
        console.log("Save location:", observerCoordinate);

        settings.setValue(kSettingLatitude, observerCoordinate.latitude);
        settings.setValue(kSettingLongitude, observerCoordinate.longitude);
        settings.setValue(kSettingAltitude, observerCoordinate.altitude);
    }

    function save() {
        console.log("Saving config:");

        settings.setValue(kSettingShowHorizon, showHorizon);
        settings.setValue(kSettingShowCompass, showCompass);
        settings.setValue(kSettingShowPopups, showPopups);
        settings.setValue(kSettingShowInfo, showInfo);
        settings.setValue(kSettingShowVideoEffects, showVideoEffects);

        settings.setValue(kSettingManualPitch, manualPitch);
        settings.setValue(kSettingManualRoll, manualRoll);
        settings.setValue(kSettingManualCompass, manualCompass);

        settings.setValue(kSettingUseRotationZAsAzimuth, useRotationZAsAzimuth);
        settings.setValue(kSettingUsePositionSourceAltitude, usePositionSourceAltitude);

        settings.setValue(kSettingLocationMode, locationMode);
        settings.setValue(kSettingMapType, mapType);
        settings.setValue(kSettingGridType, gridType);
        settings.setValue(kSettingOverviewMapStyle, overviewMapStyle);
        settings.setValue(kSettingOverviewMapType, overviewMapType);

        settings.setValue(kSettingMaximumDistance, maximumDistance);
        settings.setValue(kSettingMagneticDeclination, magneticDeclination);
        settings.setValue(kSettingFixedAltitude, fixedAltitude);
        settings.setValue(kSettingDeviceHeight, deviceHeight);
        settings.setValue(kSettingLocationThreshold, locationThreshold);
        settings.setValue(kSettingPositionSourceOffsetX, positionSourceOffsetX);
        settings.setValue(kSettingPositionSourceOffsetY, positionSourceOffsetY);
        settings.setValue(kSettingPositionSourceOffsetZ, positionSourceOffsetZ);
        settings.setValue(kSettingHorizontalAccuracyThreshold, horizontalAccuracyThreshold);
        settings.setValue(kSettingVerticalAccuracyThreshold, verticalAccuracyThreshold);

        settings.setValue(kSettingFieldOfViewX, fieldOfViewX);
        settings.setValue(kSettingFieldOfViewY, fieldOfViewY);

        settings.setValue(kSettingAzimuthFilterType, azimuthFilterType);
        settings.setValue(kSettingAzimuthRounding, azimuthRounding);
        settings.setValue(kSettingAzimuthFilterLength, azimuthFilterLength);

        settings.setValue(kSettingAttitudeFilterType, attitudeFilterType);
        settings.setValue(kSettingAttitudeRounding, attitudeRounding);
        settings.setValue(kSettingAttitudeFilterLength, attitudeFilterLength);

        settings.setValue(kSettingCompassCalibrationThreshold, compassCalibrationThreshold);

        settings.setValue(kSettingDataSourceId, dataSourceId);

        settings.setValue(kSettingPopupMinimumScale, popupMinimumScale);
        settings.setValue(kSettingPopupMaximumScale, popupMaximumScale);
        settings.setValue(kSettingPopupOpacity, popupOpacity);

        popupStyleSets.forEach(function(set) {
            popupStyleOptions.forEach(function(name) {
                var settingKey = popupStyleKey(set, name)
                settings.setValue(settingKey, config[settingKey]);
            });
        });

        log();
    }

    //--------------------------------------------------------------------------

    function log() {
        console.log("showInfo:", showInfo);
        console.log("showHorizon:", showHorizon);
        console.log("showCompass:", showCompass);
        console.log("showPopups:", showPopups);
        console.log("showVideoEffects:", showVideoEffects);

        console.log("manualPitch:", manualPitch);
        console.log("manualRoll:", manualRoll);
        console.log("manualCompass:", manualCompass);

        console.log("useRotationZAsAzimuth:", useRotationZAsAzimuth);
        console.log("usePositionSourceAltitude:", usePositionSourceAltitude);

        console.log("locationMode:", locationMode);
        console.log("mapType:", mapType);
        console.log("gridType:", gridType);
        console.log("overviewMapStyle:", overviewMapStyle);
        console.log("overviewMapType:", overviewMapType);

        console.log("maximumDistance:", maximumDistance);
        console.log("magneticDeclination:", magneticDeclination);
        console.log("fixedAltitude:", fixedAltitude);
        console.log("deviceHeight:", deviceHeight);
        console.log("locationThreshold:", locationThreshold);
        console.log("positionSourceOffsetX:", positionSourceOffsetX);
        console.log("positionSourceOffsetY:", positionSourceOffsetY);
        console.log("positionSourceOffsetZ:", positionSourceOffsetZ);
        console.log("horizontalAccuracyThreshold:", horizontalAccuracyThreshold);
        console.log("verticalAccuracyThreshold:", verticalAccuracyThreshold);

        console.log("fieldOfViewX:", fieldOfViewX);
        console.log("fieldOfViewY:", fieldOfViewY);

        console.log("azimuthFilterType:", azimuthFilterType);
        console.log("azimuthRounding:", azimuthRounding);
        console.log("azimuthFilterLength:", azimuthFilterLength);

        console.log("attitudeFilterType:", attitudeFilterType);
        console.log("attitudeRounding:", attitudeRounding);
        console.log("attitudeFilterLength:", attitudeFilterLength);

        console.log("compassCalibrationThreshold:", compassCalibrationThreshold);

        console.log("dataSourceId:", dataSourceId);

        console.log("popupMinimumScale:", popupMinimumScale);
        console.log("popupMaximumScale:", popupMaximumScale);
        console.log("popupOpacity:", popupOpacity);

        popupStyleSets.forEach(function(set) {
            popupStyleOptions.forEach(function(name) {
                var settingKey = popupStyleKey(set, name)
                console.log(settingKey, config[settingKey]);
            });
        });
    }

    //--------------------------------------------------------------------------
}
