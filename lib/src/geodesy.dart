import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// The main geodesy class
class Geodesy {
  final num _RADIUS = 6371e3; // meters
  final num _PI = math.pi;

  /// calculate a destination point given the distance and bearing
  LatLng destinationPointByDistanceAndBearing(
      LatLng l, num distance, num bearing,
      [num? radius]) {
    radius = radius ?? _RADIUS;
    final num angularDistanceRadius = distance / radius;
    final num bearingRadians = degToRadian(bearing as double);

    final num latRadians = degToRadian(l.latitude);
    final num lngRadians = degToRadian(l.longitude);

    final num sinLatRadians = math.sin(latRadians);
    final num cosLatRadians = math.cos(latRadians);
    final num sinAngularDistanceRadius = math.sin(angularDistanceRadius);
    final num cosAngularDistanceRadius = math.cos(angularDistanceRadius);
    final num sinBearingRadians = math.sin(bearingRadians);
    final num cosBearingRadians = math.cos(bearingRadians);

    final sinLatRadians2 = sinLatRadians * cosAngularDistanceRadius +
        cosLatRadians * sinAngularDistanceRadius * cosBearingRadians;
    final num latRadians2 = math.asin(sinLatRadians2);
    final y = sinBearingRadians * sinAngularDistanceRadius * cosLatRadians;
    final x = cosAngularDistanceRadius - sinLatRadians * sinLatRadians2;
    final num lngRadians2 = lngRadians + math.atan2(y, x);

    return LatLng(radianToDeg(latRadians2 as double),
        (radianToDeg(lngRadians2 as double) + 540) % 360 - 180);
  }

  /// calculate the midpoint between teo geo points
  LatLng midPointBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
    final num l1LatRadians = degToRadian(l1.latitude);
    final num l1LngRadians = degToRadian(l1.longitude);
    final num l2LatRadians = degToRadian(l2.latitude);
    final num lngRadiansDiff = degToRadian(l2.longitude - l1.longitude);

    final num vectorX = math.cos(l2LatRadians) * math.cos(lngRadiansDiff);
    final num vectorY = math.cos(l2LatRadians) * math.sin(lngRadiansDiff);

    final num x = math.sqrt(
        math.pow((math.cos(l1LatRadians) + vectorX), 2) + math.pow(vectorY, 2));
    final num y = math.sin(l1LatRadians) + math.sin(l2LatRadians);
    final num latRadians = math.atan2(y, x);
    final num lngRadians =
        l1LngRadians + math.atan2(vectorY, math.cos(l1LatRadians) + vectorX);

    return LatLng(radianToDeg(latRadians as double),
        (radianToDeg(lngRadians as double) + 540) % 360 - 180);
  }

  /// calculate the geo point of intersection of two given paths
  LatLng? intersectionByPaths(LatLng l1, LatLng l2, num b1, num b2) {
    final num l1LatRadians = degToRadian(l1.latitude);
    final num l1LngRadians = degToRadian(l1.longitude);
    final num l2LatRadians = degToRadian(l2.latitude);
    final num l2LngRadians = degToRadian(l2.longitude);
    final num b1Radians = degToRadian(b1 as double);
    final num b2Radians = degToRadian(b2 as double);

    final latRadiansDiff = l2LatRadians - l1LatRadians;
    final lngRadiansDiff = l2LngRadians - l1LngRadians;

    final num angularDistance = 2 *
        math.asin(math.sqrt(
            math.sin(latRadiansDiff / 2) * math.sin(latRadiansDiff / 2) +
                math.cos(l1LatRadians) *
                    math.cos(l2LatRadians) *
                    math.sin(lngRadiansDiff / 2) *
                    math.sin(lngRadiansDiff / 2)));

    if (angularDistance == 0) return null;

    num initBearingX = math.acos((math.sin(l2LatRadians) -
            math.sin(l1LatRadians) * math.cos(angularDistance)) /
        (math.sin(angularDistance) * math.cos(l1LatRadians)));
    if (initBearingX.isNaN) initBearingX = 0;

    num initBearingY = math.acos((math.sin(l1LatRadians) -
            math.sin(l2LatRadians) * math.cos(angularDistance)) /
        (math.sin(angularDistance) * math.cos(l2LatRadians)));

    final finalBearingX = math.sin(l2LngRadians - l1LngRadians) > 0
        ? initBearingX
        : 2 * _PI - initBearingX;
    final finalBearingY = math.sin(l2LngRadians - l1LngRadians) > 0
        ? 2 * _PI - initBearingY
        : initBearingY;

    final angle1 = b1Radians - finalBearingX;
    final angle2 = finalBearingY - b2Radians;

    if (math.sin(angle1) == 0 && math.sin(angle2) == 0) return null;
    if (math.sin(angle1) * math.sin(angle2) < 0) return null;

    final num angle3 = math.acos(-math.cos(angle1) * math.cos(angle2) +
        math.sin(angle1) * math.sin(angle2) * math.cos(angularDistance));
    final num dst13 = math.atan2(
        math.sin(angularDistance) * math.sin(angle1) * math.sin(angle2),
        math.cos(angle2) + math.cos(angle1) * math.cos(angle3));

    final num lat3 = math.asin(math.sin(l1LatRadians) * math.cos(dst13) +
        math.cos(l1LatRadians) * math.sin(dst13) * math.cos(b1Radians));

    final num lngRadiansDiff13 = math.atan2(
        math.sin(b1Radians) * math.sin(dst13) * math.cos(l1LatRadians),
        math.cos(dst13) - math.sin(l1LatRadians) * math.sin(lat3));

    final l3LngRadians = l1LngRadians + lngRadiansDiff13;

    return LatLng(radianToDeg(lat3 as double),
        (radianToDeg(l3LngRadians as double) + 540) % 360 - 180);
  }

  /// calculate the distance in meters between two geo points
  num distanceBetweenTwoGeoPoints(LatLng l1, LatLng l2, [num? radius]) {
    final R = radius ?? _RADIUS;
    final num l1LatRadians = degToRadian(l1.latitude);
    final num l1LngRadians = degToRadian(l1.longitude);
    final num l2LatRadians = degToRadian(l2.latitude);
    final num l2LngRadians = degToRadian(l2.longitude);

    final latRadiansDiff = l2LatRadians - l1LatRadians;
    final lngRadiansDiff = l2LngRadians - l1LngRadians;

    final num a = math.sin(latRadiansDiff / 2) * math.sin(latRadiansDiff / 2) +
        math.cos(l1LatRadians) *
            math.cos(l2LatRadians) *
            math.sin(lngRadiansDiff / 2) *
            math.sin(lngRadiansDiff / 2);
    final num c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = R * c;

    return distance;
  }

  /// calculate the bearing from point l1 to point l2
  num bearingBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
    final l1LatRadians = degToRadian(l1.latitude);
    final l2LatRadians = degToRadian(l2.latitude);
    final lngRadiansDiff = degToRadian(l2.longitude - l1.longitude);

    final y = math.sin(lngRadiansDiff) * math.cos(l2LatRadians);
    final x = math.cos(l1LatRadians) * math.sin(l2LatRadians) -
        math.sin(l1LatRadians) *
            math.cos(l2LatRadians) *
            math.cos(lngRadiansDiff);

    final radians = math.atan2(y, x);
    final degrees = radianToDeg(radians);

    return (degrees + 360) % 360;
  }

  /// calculate the final bearing from point l1 to point l2
  num finalBearingBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
    return (bearingBetweenTwoGeoPoints(l2, l1) + 180) % 360;
  }

  /// calculate signed distance from a geo point
  /// to create circle with start and end points
  num crossTrackDistanceTo(LatLng l1, LatLng start, LatLng end, [num? radius]) {
    final R = radius ?? _RADIUS;

    final distStartL1 = distanceBetweenTwoGeoPoints(start, l1, R) / R;
    final bearingStartL1 =
        degToRadian(bearingBetweenTwoGeoPoints(start, l1) as double);
    final bearingStartEnd =
        degToRadian(bearingBetweenTwoGeoPoints(start, end) as double);

    final x = math.asin(
        math.sin(distStartL1) * math.sin(bearingStartL1 - bearingStartEnd));

    return x * R;
  }

  /// check if a given geo point is in the bounding box
  bool isGeoPointInBoundingBox(LatLng l, LatLng topLeft, LatLng bottomRight) {
    return (bottomRight.latitude <= l.latitude &&
            l.latitude <= topLeft.latitude) &&
        (topLeft.longitude <= l.longitude &&
            l.longitude <= bottomRight.longitude);
  }

  /// check if a given geo point is in the a polygon
  /// using even-odd rule algorithm
  bool isGeoPointInPolygon(LatLng l, List<LatLng> polygon) {
    var isInPolygon = false;

    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final vertexI = polygon[i];
      final vertexJ = polygon[j];

      final aboveLatitude =
          (vertexI.latitude <= l.latitude) && (l.latitude < vertexJ.latitude);
      final belowLatitude =
          (vertexJ.latitude <= l.latitude) && (l.latitude < vertexI.latitude);
      final withinLongitude = l.longitude <
          (vertexJ.longitude - vertexI.longitude) *
                  (l.latitude - vertexI.latitude) /
                  (vertexJ.latitude - vertexI.latitude) +
              vertexI.longitude;

      if ((aboveLatitude || belowLatitude) && withinLongitude) {
        isInPolygon = !isInPolygon;
      }
    }

    return isInPolygon;
  }

  /// Get a list of [LatLng] points within a distance from
  /// a given point
  /// Distance is in meters
  List<LatLng> pointsInRange(
      LatLng point, List<LatLng> pointsToCheck, num distance) {
    final geoFencedPoints = <LatLng>[];
    for (final p in pointsToCheck) {
      if (distanceBetweenTwoGeoPoints(point, p) <= distance) {
        geoFencedPoints.add(p);
      }
    }
    return geoFencedPoints;
  }

  /// great-circle distance between two points using the Haversine formula
  num greatCircleDistanceBetweenTwoGeoPoints(
      num lat1, num lon1, num lat2, num lon2) {
    final num earthRadius = _RADIUS; // Radius of the earth in kilometers

    num dLat = degToRadian(lat2.toDouble() - lat1.toDouble());
    num dLon = degToRadian(lon2.toDouble() - lon1.toDouble());

    num a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(degToRadian(lat1.toDouble())) *
            math.cos(degToRadian(lat2.toDouble())) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    num c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    num distance = earthRadius * c;

    return distance;
  }

  /// GetRectangleBounds

  List<LatLng> getRectangleBounds(List<LatLng> polygonCoords) {
    num minLatitude = double.infinity.toDouble();
    num maxLatitude = double.negativeInfinity.toDouble();
    num minLongitude = double.infinity.toDouble();
    num maxLongitude = double.negativeInfinity.toDouble();

    for (LatLng coord in polygonCoords) {
      if (coord.latitude < minLatitude) {
        minLatitude = coord.latitude;
      }
      if (coord.latitude > maxLatitude) {
        maxLatitude = coord.latitude;
      }
      if (coord.longitude < minLongitude) {
        minLongitude = coord.longitude;
      }
      if (coord.longitude > maxLongitude) {
        maxLongitude = coord.longitude;
      }
    }

    List<LatLng> rectangleBounds = [
      LatLng(minLatitude.toDouble(), minLongitude.toDouble()),
      LatLng(minLatitude.toDouble(), maxLongitude.toDouble()),
      LatLng(maxLatitude.toDouble(), maxLongitude.toDouble()),
      LatLng(maxLatitude.toDouble(), minLongitude.toDouble()),
    ];

    return rectangleBounds;
  }

  /// Bounding Box per distance in Kilometers
  List<LatLng> calculateBoundingBox(LatLng centerPoint, num distanceInKm) {
    // Earth's radius in kilometers
    final num radiusOfEarth = _RADIUS / 1000;
    // Convert latitude to radians
    final num latInRadians = centerPoint.latitude * (_PI / 180.0);
    final num degreeLatDistance =
        (distanceInKm / radiusOfEarth) * (180.0 / _PI);
    final num degreeLngDistance = degreeLatDistance / math.cos(latInRadians);
    final num topLat = centerPoint.latitude + degreeLatDistance;
    final num leftLng = centerPoint.longitude - degreeLngDistance;
    final num bottomLat = centerPoint.latitude - degreeLatDistance;
    final num rightLng = centerPoint.longitude + degreeLngDistance;
    final LatLng topLeft = LatLng(topLat.toDouble(), leftLng.toDouble());
    final LatLng bottomRight =
        LatLng(bottomLat.toDouble(), rightLng.toDouble());
    return [topLeft, bottomRight];
  }

  /// finds the centroid of polygons:
  LatLng findPolygonCentroid(List<LatLng> polygon) {
    num x = 0;
    num y = 0;
    num signedArea = 0;

    num vertexCount = polygon.length;

    for (int i = 0; i < vertexCount; i++) {
      final LatLng currentVertex = polygon[i];
      final LatLng nextVertex = polygon[(i + 1) % vertexCount.toInt()];

      num a = currentVertex.longitude * nextVertex.latitude -
          nextVertex.longitude * currentVertex.latitude;
      signedArea += a;
      x += (currentVertex.longitude + nextVertex.longitude) * a;
      y += (currentVertex.latitude + nextVertex.latitude) * a;
    }

    signedArea *= 0.5;
    x /= (6 * signedArea);
    y /= (6 * signedArea);
    // Return the centroid as LatLng object
    return LatLng(
      y.toDouble(),
      x.toDouble(),
    );
  }

  /// Polygon Intersection
  List<LatLng> getPolygonIntersection(
      List<LatLng> polygon1, List<LatLng> polygon2) {
    final List<LatLng> intersectionPoints = <LatLng>[];

    for (int i = 0; i < polygon1.length; i++) {
      final int j = (i + 1) % polygon1.length;
      final LatLng edge1Start = polygon1[i];
      final LatLng edge1End = polygon1[j];

      for (int k = 0; k < polygon2.length; k++) {
        final int l = (k + 1) % polygon2.length;
        final LatLng edge2Start = polygon2[k];
        final LatLng edge2End = polygon2[l];

        final LatLng? intersection =
            _getLineIntersection(edge1Start, edge1End, edge2Start, edge2End);
        if (intersection != null) {
          intersectionPoints.add(intersection);
        }
      }
    }

    return intersectionPoints;
  }

  LatLng? _getLineIntersection(
      LatLng start1, LatLng end1, LatLng start2, LatLng end2) {
    final num x1 = start1.latitude;
    final num y1 = start1.longitude;
    final num x2 = end1.latitude;
    final num y2 = end1.longitude;
    final num x3 = start2.latitude;
    final num y3 = start2.longitude;
    final num x4 = end2.latitude;
    final num y4 = end2.longitude;

    final num denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denominator == 0) {
      return null; // Lines are parallel or coincident
    }

    final num intersectionX =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
            denominator;
    final num intersectionY =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
            denominator;

    final LatLng intersection =
        LatLng(intersectionX.toDouble(), intersectionY.toDouble());

    if (_isPointOnLine(intersection, start1, end1) &&
        _isPointOnLine(intersection, start2, end2)) {
      return intersection;
    } else {
      return null;
    }
  }

  bool _isPointOnLine(LatLng point, LatLng lineStart, LatLng lineEnd) {
    final minX = lineStart.latitude < lineEnd.latitude
        ? lineStart.latitude
        : lineEnd.latitude;
    final maxX = lineStart.latitude > lineEnd.latitude
        ? lineStart.latitude
        : lineEnd.latitude;
    final minY = lineStart.longitude < lineEnd.longitude
        ? lineStart.longitude
        : lineEnd.longitude;
    final maxY = lineStart.longitude > lineEnd.longitude
        ? lineStart.longitude
        : lineEnd.longitude;

    return point.latitude >= minX &&
        point.latitude <= maxX &&
        point.longitude >= minY &&
        point.longitude <= maxY;
  }
}
