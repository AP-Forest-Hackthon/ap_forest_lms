// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trainee/map/academy_map_screen.dart
//
// Academy Map with:
//   - Google Maps (primary) for standard navigation
//   - flutter_map (OpenStreetMap / ESRI Satellite) for forest area overlay
//     Best available option for Rajamahendravaram forest coverage.
//     Includes ESRI World Imagery tile layer which shows forest coverage well.
//
// GPS coordinates loaded from Firestore academySettings/location.
// Admin must set exact coordinates via the Admin panel.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../models/other_models.dart';
import '../../../repositories/user_repository.dart';

class AcademyMapScreen extends StatefulWidget {
  const AcademyMapScreen({super.key});

  @override
  State<AcademyMapScreen> createState() => _AcademyMapScreenState();
}

class _AcademyMapScreenState extends State<AcademyMapScreen> {
  final _locationService = LocationService();
  final _userRepo = UserRepository();
  final _mapController = MapController();

  AcademyLocationModel? _academyLocation;
  Position? _userPosition;
  bool _isLoadingLocation = false;
  bool _isLoadingAcademy = true;
  String? _error;
  bool _isInsideGeofence = false;
  double? _distanceMeters;

  // Map layer selector
  int _selectedLayer = 0; // 0=Street, 1=Satellite, 2=Terrain

  static const _layerOptions = [
    ('Street', 'OpenStreetMap'),
    ('Satellite', 'ESRI Imagery'),
    ('Terrain', 'ESRI Topo'),
  ];

  @override
  void initState() {
    super.initState();
    _loadAcademyLocation();
  }

  Future<void> _loadAcademyLocation() async {
    setState(() => _isLoadingAcademy = true);
    try {
      final loc = await _userRepo.getAcademyLocation();
      setState(() {
        _academyLocation = loc ??
            const AcademyLocationModel(
              latitude: AppConstants.academyDefaultLat,
              longitude: AppConstants.academyDefaultLng,
              geofenceRadiusMeters: AppConstants.defaultGeofenceRadius,
              address: AppConstants.academyAddress,
            );
        _isLoadingAcademy = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load academy location.';
        _isLoadingAcademy = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _error = null;
    });

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _error = 'Location permission is required for this feature.\n'
            'Please enable location access in device settings.';
        _isLoadingLocation = false;
      });
      return;
    }

    setState(() {
      _userPosition = position;
      _isLoadingLocation = false;
    });

    if (_academyLocation != null) {
      final dist = _locationService.calculateDistance(
        userLat: position.latitude,
        userLng: position.longitude,
        academyLat: _academyLocation!.latitude,
        academyLng: _academyLocation!.longitude,
      );
      final inside = _locationService.isInsideGeofence(
        userLat: position.latitude,
        userLng: position.longitude,
        academyLat: _academyLocation!.latitude,
        academyLng: _academyLocation!.longitude,
        radiusMeters: _academyLocation!.geofenceRadiusMeters,
      );

      setState(() {
        _distanceMeters = dist;
        _isInsideGeofence = inside;
      });

      // Center map on user location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14,
      );
    }
  }

  Future<void> _navigateToAcademy() async {
    if (_academyLocation == null) return;
    final lat = _academyLocation!.latitude;
    final lng = _academyLocation!.longitude;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String get _currentTileUrl {
    switch (_selectedLayer) {
      case 1:
        return AppConstants.esriSatelliteTileUrl;
      case 2:
        return AppConstants.esriTopoTileUrl;
      default:
        return AppConstants.osmTileUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Academy Location'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAcademyLocation,
          ),
        ],
      ),
      body: _isLoadingAcademy
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // ── Layer Selector ───────────────────────────────────────
                _buildLayerSelector(),

                // ── Map ──────────────────────────────────────────────────
                Expanded(child: _buildMap()),

                // ── Info Panel ───────────────────────────────────────────
                _buildInfoPanel(),
              ],
            ),
    );
  }

  Widget _buildLayerSelector() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          const Text('Map Style:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          ...List.generate(_layerOptions.length, (i) {
            final (label, _) = _layerOptions[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: _selectedLayer == i,
                onSelected: (_) => setState(() => _selectedLayer = i),
                selectedColor: AppColors.primarySurface,
                labelStyle: TextStyle(
                  color: _selectedLayer == i ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: _selectedLayer == i ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final academyLat = _academyLocation?.latitude ?? AppConstants.academyDefaultLat;
    final academyLng = _academyLocation?.longitude ?? AppConstants.academyDefaultLng;
    final geofenceRadius = _academyLocation?.geofenceRadiusMeters ?? AppConstants.defaultGeofenceRadius;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(academyLat, academyLng),
        initialZoom: 15,
      ),
      children: [
        // Tile Layer
        TileLayer(
          urlTemplate: _currentTileUrl,
          userAgentPackageName: 'com.apforestacademy.lms',
          subdomains: _selectedLayer == 0 ? const ['a', 'b', 'c'] : const [],
        ),

        // Geofence Circle
        CircleLayer(circles: [
          CircleMarker(
            point: LatLng(academyLat, academyLng),
            radius: geofenceRadius,
            useRadiusInMeter: true,
            color: AppColors.primary.withOpacity(0.15),
            borderColor: AppColors.primary.withOpacity(0.5),
            borderStrokeWidth: 2,
          ),
        ]),

        // Markers
        MarkerLayer(markers: [
          // Academy marker
          Marker(
            point: LatLng(academyLat, academyLng),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Text(
                    '🌿 Academy',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.location_on, color: AppColors.primary, size: 32),
              ],
            ),
          ),

          // User location marker
          if (_userPosition != null)
            Marker(
              point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '📍 You',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
        ]),

        // Attribution
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              _selectedLayer == 0
                  ? 'OpenStreetMap contributors'
                  : 'Esri — World Imagery / World Topo',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadowMedium, blurRadius: 16, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Academy name
            Row(
              children: [
                const Icon(Icons.forest, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.academyName,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Rajamahendravaram, Andhra Pradesh',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Distance & Status
            Row(
              children: [
                Expanded(child: _buildInfoChip(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: _distanceMeters != null
                      ? _locationService.formatDistance(_distanceMeters!)
                      : '--',
                  color: AppColors.info,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoChip(
                  icon: _isInsideGeofence ? Icons.verified : Icons.location_off,
                  label: 'Status',
                  value: _userPosition == null
                      ? 'Unknown'
                      : _isInsideGeofence
                          ? 'Inside Academy'
                          : 'Outside Academy',
                  color: _userPosition == null
                      ? AppColors.textHint
                      : _isInsideGeofence
                          ? AppColors.success
                          : AppColors.warning,
                )),
              ],
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingLocation ? null : _getUserLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location, size: 18),
                    label: Text(_isLoadingLocation ? 'Locating...' : 'My Location'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToAcademy,
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text('Navigate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.traineeAttendance),
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text('Mark Attendance'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              ),
            ),
            
            // Forest Map Note
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Switch to "Satellite" view to see the forest area around Rajamahendravaram using ESRI imagery.',
                      style: TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
