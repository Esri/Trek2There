.pragma library

.import "gl-matrix.js" as GLM

var tanfovx = 1.0;
var tanfovy = 1.0;
var mvVec = GLM.vec4.create();
var mvMatrix = GLM.mat4.create();
//var pMatrix = GLM.mat4.create();

//------------------------------------------------------------------------------

function toRadians(degrees) {
    return degrees * Math.PI / 180;
}

//------------------------------------------------------------------------------

function toDegrees(radians) {
    return radians * 180 / Math.PI;
}

//------------------------------------------------------------------------------

function normAngle(a) {
    return (a + 720) % 360;
}

//------------------------------------------------------------------------------

function relAngle(a) {
    return toDegrees(Math.asin(Math.sin(toRadians(a))));
}

//------------------------------------------------------------------------------

function inFieldOfView(azimuth, observerDirection, observerRoll, fieldOfViewX, fieldOfViewY) {
    var fov = getEffectiveFieldOfViewX(observerRoll, fieldOfViewX, fieldOfViewY);
    var psi = observerDirection - azimuth;

    return Math.cos( toRadians(psi) ) >= Math.cos( toRadians(fov / 2) )
}

function getEffectiveFieldOfViewX(observerRoll, fieldOfViewX, fieldOfViewY) {
    return getEffectiveFieldOfViewY(observerRoll, fieldOfViewY, fieldOfViewX);
}

function getEffectiveFieldOfViewY(observerRoll, fieldOfViewX, fieldOfViewY) {
    var diagonalFoV = Math.sqrt(fieldOfViewX * fieldOfViewX + fieldOfViewY * fieldOfViewY);
    var cosr = Math.cos( Math.atan(fieldOfViewX / fieldOfViewY) - toRadians(Math.abs(observerRoll)) );

    return diagonalFoV * cosr;
}

//------------------------------------------------------------------------------

function minDistanceVisibleInNearPlane(observerHeight, observerPitch, observerRoll, fieldOfViewX, fieldOfViewY) {
    var fov = getEffectiveFieldOfViewY(observerRoll, fieldOfViewX, fieldOfViewY);
    var tanfov = Math.tan( toRadians(fov / 2 - observerPitch) );

    return (observerHeight / tanfov);
}

function maxDistanceVisibleInNearPlane(observerHeight, observerPitch, observerRoll, fieldOfViewX, fieldOfViewY) {
    var fov = getEffectiveFieldOfViewY(observerRoll, fieldOfViewX, fieldOfViewY);
    var angle = -fov / 2 - observerPitch;

    // we can't see past the horizon
    if (angle <= 0) {
        return distanceToHorizon(observerHeight);
    }

    var tanfov = Math.tan( toRadians(angle) );

    return (observerHeight / tanfov);
}

function distanceToHorizon(height) {
    if (!height) {
        return 0;
    }

    return 3570 * Math.sqrt(height);
}

function zoomFieldOfView(fov, zoomLevel) {

    return zoomLevel === 1.0 ? fov :  2 * toDegrees( Math.atan( Math.tan( toRadians(fov / 2) ) / zoomLevel ) );
}

//------------------------------------------------------------------------------

/**
 * Set up the camera transformation matrix. The observer is at the origin of the local coordinate system and its
 * axis are defined as: x towards east, y towards north, z up.
 *
 * The axis of the camera system are given by x towards the right, y points downwards
 *
 * @param {number} height - the height of the camera above the origin (given by the observer location & elevation)
 * @param {number} yaw    - rotation angle in degrees around z axis, positive towards WEST  (x turns towards y)
 * @param {number} pitch  - rotation angle in degrees around x axis, positive towards UP    (y turns towards z)
 * @param {number} roll   - rotation angle in degrees around y axis, positive towards RIGHT (z turns towards x)
 * @param {number} fovX   - camera field of view in degrees, along the x axis of the camera system
 * @param {number} fovY   - camera field of view in degrees, along the y axis of the camera system
 *
 * NOTE: This method has to be called BEFORE doing the projection of points into the camera system and whenever the parameters are updated.
 */
function initializeTransformationMatrix(height, yaw, pitch, roll, fovX, fovY) {
    tanfovx = Math.tan( toRadians(fovX / 2) );
    tanfovy = Math.tan( toRadians(fovY / 2) );

    // XXX there seems to be some confusion here about row/column ordering of these matrices. Needs to be checked.
    GLM.mat4.identity(mvMatrix);
    GLM.mat4.rotateY(mvMatrix, mvMatrix, toRadians(roll));
    GLM.mat4.rotateX(mvMatrix, mvMatrix, toRadians(pitch));
    GLM.mat4.rotateZ(mvMatrix, mvMatrix, toRadians(yaw)); // XXX despite what was said above, this is for yaw positive towards EAST...
    GLM.mat4.translate(mvMatrix, mvMatrix, [0, 0, height]);
}

/**
 * Convert a target coordinate to a point projected into the camera system. If the target altitude is
 * not set, 0 will be used instead.
 *
 * @param {QtPositioning.coordinate} observerCoordinate - world coordinate (lat, long, altitude) of observer
 * @param {QtPositioning.coordinate} targetCoordinate   - world coordinate (lat, long, altitude) of target
 *
 * @returns {Qt.vector2d} - target coordinate projected into the camera system
 *
 * NOTE: initializeTransformationMatrix(...) must be called first to set up the camera system
 */
function transformWorldToCamera(observerCoordinate, targetCoordinate) {
    var targetAzimuth = observerCoordinate.azimuthTo(targetCoordinate);
    var targetDistance = observerCoordinate.distanceTo(targetCoordinate);
    var targetElevation = targetCoordinate.altitude - observerCoordinate.altitude;

    return transformAzimuthToCamera(targetAzimuth, targetDistance, targetElevation);
}

/**
 * Convert a point defined by azimuth, distance, and elevation to a point projected into the camera system. If
 * elevation is not set, 0 will be used instead.
 *
 * @param {number} azimuth   - azimuth in degrees from observer to target, measured from due north, positive towards east
 * @param {number} distance  - distance from observer to target
 * @param {number} elevation - target elevation with respect to the observer, negative if below, positive if above observer
 *
 * @returns {Qt.vector2d} - point projected into the camera system
 *
 * NOTE: initializeTransformationMatrix(...) must be called first to set up the camera system
 */
function transformAzimuthToCamera(azimuth, distance, elevation) {
    var pt = transformAzimuthToPoint(azimuth, distance, elevation);

    return transformPointToCamera(pt);
}

/**
 * Convert a point given in the local coordinate system adopted by the observer to a point projected into
 * the camera system.
 *
 * The observer is at the origin of the local coordinate system and its axis are defined as:
 * - x axis pointing towards east
 * - y axis pointing towards north
 * - z axis pointing up
 *
 * The origin of the camera system is at the top left of the image plane, with x pointing right and y pointing down.
 * Valid projected points have x and y coordinates ranging from 0 to 1. Projected points falling outside this range
 * are not visible in the image plane.
 *
 * @param {Qt.vector3d} pt - the 3D point to transform
 *
 * @returns {Qt.vector2d} - point projected into the camera system
 *
 * NOTE: initializeTransformationMatrix(...) must be called first to set up the camera system
 */
function transformPointToCamera(pt) {
    applyTransformToPoint(mvVec, pt);

    // screen coordinate system, x' towards right, y' towards top, z' towards observer
    // z' = -y, x' = x / z' * fx, y' = z / z' * fy, where fx, fy are 1/tan(FoVX), 1/tan(FoVY), respectively
    // point is visible (in front of the camera) if y > 0
    if (mvVec[1] > 0) {
        return projectPoint(mvVec);
    }

    return null;
}

/**
 * Transform a 3d point by the camera transformation matrix
 *
 * @param {GLM.vec4} vout - the transformed point
 * @param {Qt.vector3d} pt - the 3D point to transform
 */
function applyTransformToPoint(vout, pt) {
    GLM.vec4.set(vout, pt.x, pt.y, -pt.z, 1);  // XXX despite what was said above, this is for z pointing down

    // rotate world points into camera view - make sure mvMatrix has been initialized!
    GLM.vec4.transformMat4(vout, vout, mvMatrix);
}

/**
 * Project a 3D point into the camera system.
 *
 * @param {Qt.vector3d} pt - the 3d point in the view frustrum to convert
 *
 * @returns {Qt.vector2d} - point projected into the camera system
 *
 * NOTE: initializeTransformationMatrix(...) must be called first to set up the camera system
 */
function projectPoint(pt) {
    // screen coordinate system, x' towards right, y' towards top, z' towards observer
    // z' = -y, x' = x / z' * fx, y' = z / z' * fy, where fx, fy are 1/tan(FoVX), 1/tan(FoVY), respectively
    // point is visible (in front of the camera) if y > 0
    var x = - pt[0] / pt[1] / tanfovx;
    var y = - pt[2] / pt[1] / tanfovy;

    var xval = (1 - x) / 2;
    var yval = (1 - y) / 2;

    return Qt.vector2d(xval, yval);
}

/**
 * Convert a point defined by azimuth, distance, and elevation to a point in the local coordinate system adopted by the observer.
 * If elevation is not set, 0 will be used instead.
 *
 * @param {number} azimuth   - azimuth in degrees from observer to target, measured from due north, positive towards east
 * @param {number} distance  - distance from observer to target
 * @param {number} elevation - target elevation with respect to the observer, negative if below, positive if above observer
 *
 * @returns {Qt.vector3d} - point in the local coordinate system adopted by the observer
 */
function transformAzimuthToPoint(azimuth, distance, elevation) {
    var cosa = Math.cos( toRadians(azimuth) );
    var sina = Math.sin( toRadians(azimuth) );

    var x = distance * sina;
    var y = distance * cosa;
    var z = elevation ? elevation : 0;

    return Qt.vector3d(x, y, z);
}

//------------------------------------------------------------------------------

// XXX works like a charm as long as roll is zero... :(
var mvVec1 = GLM.vec4.create();
var mvVec2 = GLM.vec4.create();
var mvDir = GLM.vec4.create();
function transformLineToCamera(pt1, pt2) {
//console.log("input", GLM.vec4.str(mvVec1), GLM.vec4.str(mvVec2));

    applyTransformToPoint(mvVec1, pt1);
    applyTransformToPoint(mvVec2, pt2);

//console.log("transformed", GLM.vec4.str(mvVec1), GLM.vec4.str(mvVec2));

    // screen coordinate system, x' towards right, y' towards top, z' towards observer
    // z' = -y, x' = x / z' * fx, y' = z / z' * fy, where fx, fy are 1/tan(FoVX), 1/tan(FoVY), respectively
    // point is visible (in front of the camera) if y > 0
    var s;

//s = - (mvVec1[0] + mvVec1[1] * tanfovx) / (mvDir[0] + mvDir[1] * tanfovx); // left
//s = - (mvVec1[0] - mvVec1[1] * tanfovx) / (mvDir[0] - mvDir[1] * tanfovx); // right
//s = - (mvVec1[2] + mvVec1[1] * tanfovy) / (mvDir[2] + mvDir[1] * tanfovy); // upper
//s = - (mvVec1[2] - mvVec1[1] * tanfovy) / (mvDir[2] - mvDir[1] * tanfovy); // lower

    if (mvVec1[1] >= 0 && mvVec2[1] >= 0) {

//console.log("Case1", GLM.vec4.str(mvVec1), GLM.vec4.str(mvVec2));
        return [projectPoint(mvVec1), projectPoint(mvVec2)];

    } else if (mvVec1[1] < 0 && mvVec2[1] >= 0) {

        GLM.vec4.sub(mvDir, mvVec2, mvVec1);
        GLM.vec4.normalize(mvDir, mvDir);
//console.log("line", GLM.vec4.str(mvVec1),"+ s *", GLM.vec4.str(mvDir));

        s = - (mvVec1[2] - mvVec1[1] * tanfovy) / (mvDir[2] - mvDir[1] * tanfovy);
//        if (mvVec1[0] <= 0) {
//            s = - (mvVec1[0] + mvVec1[1] * tanfovx) / (mvDir[0] + mvDir[1] * tanfovx);
//        } else {
//            s = - (mvVec1[0] - mvVec1[1] * tanfovx) / (mvDir[0] - mvDir[1] * tanfovx);
//        }

        GLM.vec4.scaleAndAdd(mvVec1, mvVec1, mvDir, s);

//console.log("Case2", GLM.vec4.str(mvVec1), GLM.vec4.str(mvVec2), s);
        return [projectPoint(mvVec1), projectPoint(mvVec2)];

    } else if (mvVec1[1] >= 0 && mvVec2[1] < 0) {

        GLM.vec4.sub(mvDir, mvVec1, mvVec2);
        GLM.vec4.normalize(mvDir, mvDir);

        s = - (mvVec2[2] - mvVec2[1] * tanfovy) / (mvDir[2] - mvDir[1] * tanfovy);
//        if (mvVec2[0] <= 0) {
//            s = - (mvVec2[0] + mvVec2[1] * tanfovx) / (mvDir[0] + mvDir[1] * tanfovx);
//        } else {
//            s = - (mvVec2[0] - mvVec2[1] * tanfovx) / (mvDir[0] - mvDir[1] * tanfovx);
//        }

        GLM.vec4.scaleAndAdd(mvVec2, mvVec2, mvDir, s);

//console.log("Case3", GLM.vec4.str(mvVec1), GLM.vec4.str(mvVec2), s);
        return [projectPoint(mvVec2), projectPoint(mvVec1)];

    }

//console.log("Case4", GLM.vec4.str(mvVec1), GLM.vec4.str(mvVec2));
    return null;
}

//------------------------------------------------------------------------------
// The following methods are deprecated, to be removed
//------------------------------------------------------------------------------

/**
 * @deprecated
 */
function inFieldOfViewOld(observerCoordinate, targetCoordinate, observerDirection, fieldOfViewX) {
    var psi = observerDirection - observerCoordinate.azimuthTo(targetCoordinate);

    return Math.cos( toRadians(psi) ) >= Math.cos( toRadians(fieldOfViewX / 2) )
}

/**
 * @deprecated
 */
function scaledNearPlaneIntersectionFromPoint(observerCoordinate, targetCoordinate, observerHeight, observerDirection, observerPitch, fieldOfViewX, fieldOfViewY) {
    var azimuth = observerCoordinate.azimuthTo(targetCoordinate);
    var targetDistance = observerCoordinate.distanceTo(targetCoordinate);

    return scaledNearPlaneIntersection(observerHeight, observerDirection, observerPitch, fieldOfViewX, fieldOfViewY, targetDistance, azimuth);
}

/**
 * @deprecated
 */
function scaledNearPlaneIntersection(observerHeight, observerDirection, observerPitch, fieldOfViewX, fieldOfViewY, targetDistance, azimuth) {
    var psi = observerDirection - azimuth;

    var targetDistanceX = targetDistance * Math.sin( toRadians(psi) );
    var targetDistanceY = targetDistance * Math.cos( toRadians(psi) );

    var xInNearPlane = scaledWidthInNearPlane(observerHeight, observerPitch, fieldOfViewX, fieldOfViewY, targetDistanceX, targetDistanceY);
    var yInNearPlane = scaledHeightInNearPlane(observerHeight, observerPitch, fieldOfViewY, targetDistanceY);

    return Qt.vector2d(xInNearPlane, yInNearPlane);
}

/**
 * @deprecated
 */
function scaledWidthInNearPlane(observerHeight, observerPitch, fieldOfViewX, fieldOfViewY, targetDistanceX, targetDistanceY) {
    var width     = widthInNearPlane(observerHeight, observerPitch, fieldOfViewY, targetDistanceX, targetDistanceY);
    var halfWidth = halfWidthOfNearPlane(observerHeight, observerPitch, fieldOfViewX, fieldOfViewY);

    return (1 - width / halfWidth) / 2;
}

/**
 * @deprecated
 */
function scaledHeightInNearPlane(observerHeight, observerPitch, fieldOfViewY, targetDistanceY) {
    var height     = heightInNearPlane(observerHeight, observerPitch, fieldOfViewY, targetDistanceY);
    var halfHeight = halfHeightOfNearPlane(observerHeight, observerPitch, fieldOfViewY);

    return (1 - height / halfHeight) / 2;
}

/**
 * @deprecated
 */
function scaledHorizonHeightInNearPlane(observerHeight, observerPitch, fieldOfViewY) {
    var horHeight  = horizonHeightInNearPlane(observerHeight, observerPitch, fieldOfViewY);
    var halfHeight = halfHeightOfNearPlane(observerHeight, observerPitch, fieldOfViewY);

    return (1 - horHeight / halfHeight) / 2;
}

/**
 * @deprecated
 */
function widthInNearPlane(observerHeight, observerPitch, fieldOfViewY, targetDistanceX, targetDistanceY) {
//    var cosphi   = Math.cos( toRadians(-observerPitch) );
//    var sinphi   = Math.sin( toRadians(-observerPitch) );
//    var cosfovy  = Math.cos( toRadians(fieldOfViewY / 2) );
//    var sinfovyt = Math.sin( toRadians(fieldOfViewY / 2 - observerPitch) );
//    return observerHeight * cosfovy / sinfovyt * targetDistanceX / (targetDistanceY * cosphi + observerHeight * sinphi);

    var cosphi   = Math.cos( toRadians(-observerPitch) );
    var sinphi   = Math.sin( toRadians(-observerPitch) );

    return targetDistanceX / (targetDistanceY * cosphi + observerHeight * sinphi);
}

/**
 * @deprecated
 */
function heightInNearPlane(observerHeight, observerPitch, fieldOfViewY, targetDistanceY) {
//    var cosphi   = Math.cos( toRadians(-observerPitch) );
//    var sinphi   = Math.sin( toRadians(-observerPitch) );
//    var cosfovy  = Math.cos( toRadians(fieldOfViewY / 2) );
//    var sinfovyt = Math.sin( toRadians(fieldOfViewY / 2 - observerPitch) );
//    return observerHeight * cosfovy / sinfovyt * (targetDistanceY * sinphi - observerHeight * cosphi) / (targetDistanceY * cosphi + observerHeight * sinphi);

    var cosphi   = Math.cos( toRadians(-observerPitch) );
    var sinphi   = Math.sin( toRadians(-observerPitch) );

    return (targetDistanceY * sinphi - observerHeight * cosphi) / (targetDistanceY * cosphi + observerHeight * sinphi);
}

/**
 * @deprecated
 */
function halfWidthOfNearPlane(observerHeight, observerPitch, fieldOfViewX, fieldOfViewY) {
//    var cosfovy  = Math.cos( toRadians(fieldOfViewY / 2) );
//    var sinfovyt = Math.sin( toRadians(fieldOfViewY / 2 - observerPitch) );
//    var tanfovx  = Math.tan( toRadians(fieldOfViewX / 2) );
//    return (observerHeight * cosfovy / sinfovyt * tanfovx);

    return Math.tan( toRadians(fieldOfViewX / 2) );
}

/**
 * @deprecated
 */
function halfHeightOfNearPlane(observerHeight, observerPitch, fieldOfViewY) {
//    var cosfovy  = Math.cos( toRadians(fieldOfViewY / 2) );
//    var sinfovyt = Math.sin( toRadians(fieldOfViewY / 2 - observerPitch) );
//    var tanfovy  = Math.tan( toRadians(fieldOfViewY / 2) );
//    return (observerHeight * cosfovy / sinfovyt * tanfovy);

    return Math.tan( toRadians(fieldOfViewY / 2) );
}

/**
 * @deprecated
 */
function horizonHeightInNearPlane(observerHeight, observerPitch, fieldOfViewY) {
//    var tanfovy = Math.tan( toRadians(fieldOfViewY / 2) );
//    var tanphi  = Math.tan( toRadians(-observerPitch) );
//    return halfHeightOfNearPlane(observerHeight, observerPitch, fieldOfViewY) * tanphi / tanfovy;

    return Math.tan( toRadians(-observerPitch) );
}

/**
 * @deprecated
 */
function viewingAngleToAngleInPlane(observerHeight, observerPitch, targetDistanceY, viewingAngle) {
    var gamma = toDegrees( Math.atan(observerHeight / targetDistanceY) );
    var cosgt = Math.cos( toRadians(gamma + observerPitch) );
    var tanva = Math.tan( toRadians(viewingAngle) );

    return toDegrees( Math.atan(tanva * cosgt) );
}
