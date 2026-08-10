import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';
import '../../../core/theme/app_colors.dart';

class FacultyListScreen extends StatefulWidget {
  const FacultyListScreen({super.key});

  @override
  State<FacultyListScreen> createState() => _FacultyListScreenState();
}

class _FacultyListScreenState extends State<FacultyListScreen> {
  final UserRepository _userRepo = UserRepository();

  void _showFacultyDetails(UserModel faculty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(faculty.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${faculty.email}'),
            if (faculty.subject != null) Text('Subject: ${faculty.subject}'),
            if (faculty.designation != null) Text('Designation: ${faculty.designation}'),
            if (faculty.department != null) Text('Department: ${faculty.department}'),
            Text('Status: ${faculty.status}'),
            const SizedBox(height: 10),
            Text('Created: ${faculty.createdAt?.toLocal().toString().split('.')[0] ?? "Unknown"}'),
          ],
        ),
        actions: [
          if (faculty.status == 'pending') ...[
            TextButton(
              onPressed: () async {
                await _userRepo.rejectFaculty(faculty.uid);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _userRepo.approveFaculty(faculty.uid);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFacultyList(Stream<List<UserModel>> stream) {
    return StreamBuilder<List<UserModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('No faculty found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final faculty = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Text(faculty.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                ),
                title: Text(faculty.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(faculty.email),
                trailing: _buildStatusBadge(faculty.status),
                onTap: () => _showFacultyDetails(faculty),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Faculty Management', style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pending Requests'),
              Tab(text: 'All Faculty'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFacultyList(_userRepo.getPendingFacultyRequests()),
            _buildFacultyList(_userRepo.getAllFaculty()),
          ],
        ),
      ),
    );
  }
}
