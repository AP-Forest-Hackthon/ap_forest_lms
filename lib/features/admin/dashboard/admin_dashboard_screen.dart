// ─────────────────────────────────────────────────────────────────────────────
// lib/features/admin/dashboard/admin_dashboard_screen.dart
// Admin Dashboard with Faculty Approval Workflow & LMS Administration.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Widget child;
  const AdminDashboardScreen({super.key, required this.child});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _index = 0;
  final _tabs = [
    RouteNames.adminDashboard,
    RouteNames.adminFacultyList,
    RouteNames.adminTraineeList,
    RouteNames.analytics,
    RouteNames.adminAnnouncements,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          context.go(_tabs[i]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Faculty',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Trainees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Announce',
          ),
        ],
      ),
    );
  }
}

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> with SingleTickerProviderStateMixin {
  final _userRepo = UserRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined, color: Colors.white),
            tooltip: 'Trainee Attendance',
            onPressed: () => context.go(RouteNames.adminAttendanceList),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending Requests'),
            Tab(text: 'Approved Faculty'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FacultyRequestsList(userRepo: _userRepo, filterStatus: 'pending'),
          _FacultyRequestsList(userRepo: _userRepo, filterStatus: 'active'),
          _FacultyRequestsList(userRepo: _userRepo, filterStatus: 'rejected'),
        ],
      ),
    );
  }
}

class _FacultyRequestsList extends StatelessWidget {
  final UserRepository userRepo;
  final String filterStatus;

  const _FacultyRequestsList({required this.userRepo, required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: userRepo.getFacultyByStatus(filterStatus),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  filterStatus == 'pending' ? Icons.check_circle_outline : Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  filterStatus == 'pending'
                      ? 'No pending faculty registration requests.'
                      : 'No $filterStatus faculty members found.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final faculty = requests[index];
            return _FacultyRequestCard(faculty: faculty, userRepo: userRepo);
          },
        );
      },
    );
  }
}

class _FacultyRequestCard extends StatelessWidget {
  final UserModel faculty;
  final UserRepository userRepo;

  const _FacultyRequestCard({required this.faculty, required this.userRepo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF3E5F5),
                child: Text(
                  faculty.name.isNotEmpty ? faculty.name[0].toUpperCase() : 'F',
                  style: const TextStyle(color: Color(0xFF4A148C), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      faculty.email,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(faculty.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.book, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Subject: ${faculty.subject ?? 'Not specified'}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),

          if (faculty.status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userRepo.approveFaculty(faculty.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ Approved ${faculty.name} for Faculty access.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await userRepo.rejectFaculty(faculty.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Rejected request for ${faculty.name}.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final (label, color) = switch (status) {
      'active' || 'approved' => ('Approved', AppColors.success),
      'pending' => ('Pending', AppColors.warning),
      'rejected' => ('Rejected', AppColors.error),
      _ => (status.toUpperCase(), AppColors.textHint),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
