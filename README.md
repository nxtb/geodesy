# Geodesy

[![pub package](https://img.shields.io/pub/v/geodesy.svg)](https://pub.dartlang.org/packages/geodesy)

## About

A Dart library for implementing geodesic and trigonometric calculations based on a spherical Earth model for working with points and paths such as distances, bearings and destinations.

## How to Use Geodesy

### Commands

#### For Dart

```dart
dart pub add geodesy
```

#### For Flutter

```dart
flutter pub add geodesy
```

### Import the library in your dart file

```dart
import 'package:geodesy/geodesy.dart';
```

### Initialization

```dart
final Geodesy geodesy = Geodesy();
```

## Class

The Geodesy class provides a collection of methods for performing various geodetic calculations, including distance calculations, point intersections, and more. This class is designed to work with geographical coordinates in the form of latitude and longitude.

Please see the details [here](doc/CLASS.md).

## Static Methods

Static methods are avilable without using Geodesy instance.

Please see the details  [here](doc/METHODS.md).

## Example - Geodesy Class

Please check out [here](example/main.dart) for more.

```dart
import 'package:geodesy/geodesy.dart';

void main() {
  final Geodesy geodesy = Geodesy();
  // Calculate Bounding Box
  // Example central position (San Francisco)
  final centerPoint = const LatLng(37.7749, -122.4194);
  // Example distance in kilometers
  final distanceInKm = 1.0;

  final boundingBox = geodesy.calculateBoundingBox(centerPoint, distanceInKm);

  print('[calculateBoundingBox]: ');
  print(' > Top Left: ${boundingBox[0]}');
  print(' > Bottom Right: ${boundingBox[1]}');

  // Polygon Centroid
  List<LatLng> polygon = [
    const LatLng(0, 0),
    const LatLng(4, 0),
    const LatLng(4, 4),
    const LatLng(0, 4)
  ];

  LatLng centroid = geodesy.findPolygonCentroid(polygon);

  print("Centroid: ${centroid.latitude}, ${centroid.longitude}");

  // Polygon Intersection
  final List<LatLng> polygon1 = [
    const LatLng(0, 0),
    const LatLng(0, 2),
    const LatLng(2, 2),
    const LatLng(2, 0),
  ];

  final List<LatLng> polygon2 = [
    const LatLng(1, 1),
    const LatLng(1, 3),
    const LatLng(3, 3),
    const LatLng(3, 1),
  ];

  final List<LatLng> intersectionPoints =
      geodesy.getPolygonIntersection(polygon1, polygon2);

  print('Intersection Points:');
  for (final point in intersectionPoints) {
    print('Latitude: ${point.latitude}, Longitude: ${point.longitude}');
  }
}

// Calculate Area
final outerPolygon = [
  const LatLng(0.0, 0.0),
  const LatLng(0.0, 1.0),
  const LatLng(1.0, 1.0),
  const LatLng(1.0, 0.0),
];

// Define a hole within the outer polygon
final hole1 = [
  const LatLng(0.25, 0.25),
  const LatLng(0.25, 0.75),
  const LatLng(0.75, 0.75),
  const LatLng(0.75, 0.25),
];

final holes = [hole1];
final calculatedArea =
    geodesy.calculatePolygonWithHolesArea(outerPolygon, holes);
```

## Example Static Methods

```dart
import 'package:geodesy/geodesy.dart';

void main() {
  // Calculate Bounding Box
  // Example central position (San Francisco)
  final centerPoint = const LatLng(37.7749, -122.4194);
  // Example distance in kilometers
  final distanceInKm = 1.0;
  // Static Method
  final boundingBox =
      BoundingBox.calculateBoundingBox(centerPoint, distanceInKm);

  print('[calculateBoundingBox]: ');
  print(' > Top Left: ${boundingBox[0]}');
  print(' > Bottom Right: ${boundingBox[1]}');

  // Polygon Centroid
  List<LatLng> polygon = [
    const LatLng(0, 0),
    const LatLng(4, 0),
    const LatLng(4, 4),
    const LatLng(0, 4)
  ];
  // Static Method
  final LatLng centroid = PolygonCentroid.findPolygonCentroid(polygon);

  print("Centroid: ${centroid.latitude}, ${centroid.longitude}");

  // Polygon Intersection
  final List<LatLng> polygon1 = [
    const LatLng(0, 0),
    const LatLng(0, 2),
    const LatLng(2, 2),
    const LatLng(2, 0),
  ];

  final List<LatLng> polygon2 = [
    const LatLng(1, 1),
    const LatLng(1, 3),
    const LatLng(3, 3),
    const LatLng(3, 1),
  ];
  // Static Method
  final List<LatLng> intersectionPoints =
      PolygonIntersection.getPolygonIntersection(polygon1, polygon2);

  print('Intersection Points:');
  for (final point in intersectionPoints) {
    print('Latitude: ${point.latitude}, Longitude: ${point.longitude}');
  }
}
// Static Method
final outerPolygon = [
    const LatLng(0.0, 0.0),
    const LatLng(0.0, 1.0),
    const LatLng(1.0, 1.0),
    const LatLng(1.0, 0.0),
  ];

  final hole1 = [
    const LatLng(0.25, 0.25),
    const LatLng(0.25, 0.75),
    const LatLng(0.75, 0.75),
    const LatLng(0.75, 0.25),
  ];

  final holes = [hole1];
final area = Polygon.calculatePolygonWithHolesArea(outerPolygon, holes);
```

## Code of Conduct

See [here](doc/CODE_OF_CONDUCT.md).

## License

See [here](./LICENSE).