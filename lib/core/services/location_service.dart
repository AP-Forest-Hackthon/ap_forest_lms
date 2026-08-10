// ─────────────────────────────────────────────────────────────────────────────
// lib/core/services/location_service.dart
// GPS / Geofence service for Academy Map feature.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // ── Permission ─────────────────────────────────────────────────────────────

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // ── Get Current Location ──────────────────────────────────────────────────

  Future<Position?> getCurrentLocation() async {
    final hasPermission = await hasLocationPermission();
    if (!hasPermission) {
      final granted = await requestLocationPermission();
      if (!granted) return null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  // ── Distance Calculation ──────────────────────────────────────────────────

  /// Returns distance in meters between current position and academy coords.
  double calculateDistance({
    required double userLat,
    required double userLng,
    required double academyLat,
    required double academyLng,
  }) {
    return Geolocator.distanceBetween(userLat, userLng, academyLat, academyLng);
  }

  // ── Geofence Check ────────────────────────────────────────────────────────

  bool isInsideGeofence({
    required double userLat,
    required double userLng,
    required double academyLat,
    required double academyLng,
    required double radiusMeters,
  }) {
    final distance = calculateDistance(
      userLat: userLat,
      userLng: userLng,
      academyLat: academyLat,
      academyLng: academyLng,
    );
    return distance <= radiusMeters;
  }

  // ── Format Distance ───────────────────────────────────────────────────────

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
