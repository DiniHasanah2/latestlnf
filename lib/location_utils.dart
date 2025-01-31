import 'dart:math';

class LocationUtils {
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const int radiusOfEarthInMeters = 6371000; // Radius of the Earth in meters

    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLng = _degreesToRadians(endLongitude - startLongitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceInMeters = radiusOfEarthInMeters * c;

    // Convert distance to kilometers
    double distanceInKilometers = distanceInMeters / 1000;

    return distanceInKilometers;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
