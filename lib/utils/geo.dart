import 'dart:math';

/// Returns distance in kilometers between two points using Haversine formula
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371.0; // km

  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lng2 - lng1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _toRad(double degree) => degree * pi / 180;
