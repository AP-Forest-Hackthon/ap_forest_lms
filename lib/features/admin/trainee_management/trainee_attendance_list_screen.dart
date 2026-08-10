import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/attendance_model.dart';
import 'package:intl/intl.dart';

class TraineeAttendanceListScreen extends StatelessWidget {
  const TraineeAttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainee Attendance Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('timestamp', descending: true)
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
              child: Text('No attendance records found.'),
            );
          }

          final records = snapshot.data!.docs.map(
            (d) => AttendanceRecord.fromMap(d.data() as Map<String, dynamic>, d.id)
          ).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
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
                title: Text(record.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$time\nStatus: ${record.status}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.map_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lat: ${record.latitude}, Lng: ${record.longitude}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
