import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  Position? _currentPosition;
  bool _isInsideAcademy = false;
  
  // Academy Coordinates (Rajamahendravaram Forest Academy)
  static const double academyLat = 17.0005;
  static const double academyLng = 81.7770;
  static const double geofenceRadiusMeters = 500.0;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() => _isLoading = true);
    
    final position = await _locationService.getCurrentLocation();
    
    if (position != null && mounted) {
      final isInside = _locationService.isInsideGeofence(
        userLat: position.latitude,
        userLng: position.longitude,
        academyLat: academyLat,
        academyLng: academyLng,
        radiusMeters: geofenceRadiusMeters,
      );
      
      setState(() {
        _currentPosition = position;
        _isInsideAcademy = isInside;
      });
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAttendance() async {
    if (!_isInsideAcademy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be inside the Academy campus to mark attendance.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) throw Exception('User not found');

      final record = AttendanceRecord(
        id: '',
        userId: user.uid,
        userName: user.name,
        timestamp: DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        isInsideGeofence: true,
        status: 'Present',
      );

      await FirebaseFirestore.instance.collection('attendance').add(record.toMap());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking attendance: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkLocation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              _isInsideAcademy ? Icons.location_on : Icons.location_off,
                              size: 48,
                              color: _isInsideAcademy ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isInsideAcademy ? 'Inside Academy Campus' : 'Outside Academy Campus',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isInsideAcademy 
                                  ? 'You can mark your attendance for today.' 
                                  : 'Move inside the Geofence (${geofenceRadiusMeters.toInt()}m) to mark attendance.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isInsideAcademy ? _markAttendance : null,
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Mark Present'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _checkLocation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Location'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Recent Attendance History (Optional, can just list the recent docs)
                    const Text(
                      'Recent Attendance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('attendance')
                          .where('userId', isEqualTo: context.read<AuthProvider>().user?.uid)
                          .orderBy('timestamp', descending: true)
                          .limit(10)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No recent attendance records.', style: TextStyle(color: AppColors.textHint)),
                            ),
                          );
                        }

                        final records = snapshot.data!.docs.map(
                          (d) => AttendanceRecord.fromMap(d.data() as Map<String, dynamic>, d.id)
                        ).toList();

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final time = DateFormat('MMM dd, yyyy - hh:mm a').format(record.timestamp);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: record.status == 'Present' ? AppColors.successLight : AppColors.errorLight,
                                child: Icon(
                                  record.status == 'Present' ? Icons.check : Icons.close,
                                  color: record.status == 'Present' ? AppColors.success : AppColors.error,
                                ),
                              ),
                              title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Status: ${record.status}'),
                              trailing: const Icon(Icons.location_on, size: 16, color: AppColors.textHint),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
