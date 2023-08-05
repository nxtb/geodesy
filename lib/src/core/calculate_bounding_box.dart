import 'core.dart';

/// Bounding Box per distance in Kilometers
List<LatLng> cBoundingBox(LatLng centerPoint, num distanceInKm) {
  // Earth's radius in kilometers
  final num radiusOfEarth = 6371e3 / 1000;
  // Convert latitude to radians
  final num latInRadians = centerPoint.latitude * (pi / 180.0);
  final num degreeLatDistance = (distanceInKm / radiusOfEarth) * (180.0 / pi);
  final num degreeLngDistance = degreeLatDistance / cos(latInRadians);
  final num topLat = centerPoint.latitude + degreeLatDistance;
  final num leftLng = centerPoint.longitude - degreeLngDistance;
  final num bottomLat = centerPoint.latitude - degreeLatDistance;
  final num rightLng = centerPoint.longitude + degreeLngDistance;
  final LatLng topLeft = LatLng(topLat.toDouble(), leftLng.toDouble());
  final LatLng bottomRight = LatLng(bottomLat.toDouble(), rightLng.toDouble());
  return [topLeft, bottomRight];
}
