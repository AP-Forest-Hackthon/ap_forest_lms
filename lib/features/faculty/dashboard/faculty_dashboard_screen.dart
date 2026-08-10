// ─────────────────────────────────────────────────────────────────────────────
// lib/features/faculty/dashboard/faculty_dashboard_screen.dart
// Faculty Dashboard with Subject info, Classes, Study Materials, Videos, Quizzes,
// and Live Classes (Google Meet & Zoom meeting link management).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/user_model.dart';
import '../../../models/live_class_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/live_class_repository.dart';

class FacultyDashboardScreen extends StatefulWidget {
  final Widget child;
  const FacultyDashboardScreen({super.key, required this.child});

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  int _index = 0;
  final _tabs = [
    RouteNames.facultyDashboard,
    RouteNames.facultyCourses,
    RouteNames.aiQuizGenerator,
    RouteNames.traineePerformance,
    RouteNames.facultyProfile,
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'AI Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Performance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FacultyHomeTab extends StatelessWidget {
  const FacultyHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final liveClassRepo = LiveClassRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome Header with Faculty Subject
          _buildFacultyHeader(user),
          const SizedBox(height: 20),

          // Core Actions Grid
          const Text('LMS Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildActionGrid(context),

          const SizedBox(height: 24),

          // Live Class Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Classes (Google Meet & Zoom)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () => _showCreateLiveClassDialog(context, user, liveClassRepo),
                icon: const Icon(Icons.video_call, size: 18),
                label: const Text('Create Live'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLiveClassesSection(user, liveClassRepo),
        ],
      ),
    );
  }

  Widget _buildFacultyHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.name ?? 'Faculty Member'}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Subject: ${user?.subject ?? 'Forest Management'}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      (Icons.auto_awesome, 'AI Quiz Generator', 'PDF → MCQs', RouteNames.aiQuizGenerator, AppColors.primary),
      (Icons.upload_file, 'Upload Material', 'Notes & PDFs', RouteNames.pdfUpload, const Color(0xFF1565C0)),
      (Icons.menu_book, 'My Classes', 'Manage Subjects', RouteNames.facultyCourses, const Color(0xFF00695C)),
      (Icons.quiz_outlined, 'Quizzes & Results', 'Review Submissions', RouteNames.facultyCourses, const Color(0xFFE65100)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final (icon, title, subtitle, route, color) = actions[index];
        return GestureDetector(
          onTap: () => context.go(route),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveClassesSection(UserModel? user, LiveClassRepository repo) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<LiveClassModel>>(
      stream: repo.getFacultyLiveClasses(user.uid),
      builder: (context, snapshot) {
        final liveClasses = snapshot.data ?? [];
        if (liveClasses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'No live classes scheduled yet.\nTap "Create Live" to add Google Meet or Zoom link.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          );
        }

        return Column(
          children: liveClasses.map((item) => _FacultyLiveClassCard(liveClass: item, repo: repo)).toList(),
        );
      },
    );
  }

  void _showCreateLiveClassDialog(BuildContext context, UserModel? user, LiveClassRepository repo) {
    if (user == null) return;
    final topicCtrl = TextEditingController();
    final meetCtrl = TextEditingController(text: 'https://meet.google.com/');
    final zoomCtrl = TextEditingController(text: 'https://zoom.us/j/');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Live Class Session'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: topicCtrl,
                decoration: const InputDecoration(labelText: 'Topic / Lesson Title *'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: meetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Google Meet URL (Optional)',
                  prefixIcon: Icon(Icons.video_camera_front, color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: zoomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Zoom Meeting URL (Optional)',
                  prefixIcon: Icon(Icons.video_call, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (topicCtrl.text.trim().isEmpty) return;
              final now = DateTime.now();
              final live = LiveClassModel(
                id: '',
                subject: user.subject ?? 'Forest Management',
                topic: topicCtrl.text.trim(),
                facultyId: user.uid,
                facultyName: user.name,
                date: now,
                startTime: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                endTime: '${now.hour + 1}:${now.minute.toString().padLeft(2, '0')}',
                googleMeetUrl: meetCtrl.text.trim(),
                zoomUrl: zoomCtrl.text.trim(),
              );
              await repo.createLiveClass(live);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _FacultyLiveClassCard extends StatelessWidget {
  final LiveClassModel liveClass;
  final LiveClassRepository repo;

  const _FacultyLiveClassCard({required this.liveClass, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.live_tv, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  liveClass.topic,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () => repo.deleteLiveClass(liveClass.id),
              ),
            ],
          ),
          Text(
            'Subject: ${liveClass.subject}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (liveClass.hasGoogleMeet) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.video_camera_front, size: 16, color: Colors.red),
                        SizedBox(width: 6),
                        Text('Google Meet Set', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (liveClass.hasZoom) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.video_call, size: 16, color: Colors.blue),
                        SizedBox(width: 6),
                        Text('Zoom Set', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
