// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trainee/dashboard/trainee_dashboard_screen.dart
// Student / Trainee Dashboard with User ID, Classes, Learning Resources, and
// Live Classes (Google Meet & Zoom launch buttons).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../models/user_model.dart';
import '../../../models/course_model.dart';
import '../../../models/other_models.dart';
import '../../../models/live_class_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/course_repository.dart';
import '../../../repositories/resource_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../repositories/live_class_repository.dart';

// ── Shell Screen (holds bottom nav) ──────────────────────────────────────────

class TraineeDashboardScreen extends StatefulWidget {
  final Widget child;
  const TraineeDashboardScreen({super.key, required this.child});

  @override
  State<TraineeDashboardScreen> createState() => _TraineeDashboardScreenState();
}

class _TraineeDashboardScreenState extends State<TraineeDashboardScreen> {
  int _currentIndex = 0;

  final _tabs = [
    RouteNames.traineeDashboard,
    RouteNames.traineeCourses,
    RouteNames.library,
    RouteNames.quizList,
    RouteNames.traineeProfile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) {
            setState(() => _currentIndex = idx);
            context.go(_tabs[idx]);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              activeIcon: Icon(Icons.quiz),
              label: 'Quizzes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab Content ───────────────────────────────────────────────────────────

class TraineeHomeTab extends StatelessWidget {
  const TraineeHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final courseRepo = CourseRepository();
    final resourceRepo = ResourceRepository();
    final userRepo = UserRepository();
    final liveClassRepo = LiveClassRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    _StatsRow(user: user, userRepo: userRepo),
                    const SizedBox(height: 24),

                    // Upcoming Live Classes (Google Meet / Zoom)
                    const _SectionHeader(title: 'Upcoming Live Classes'),
                    const SizedBox(height: 12),
                    _TraineeLiveClassesSection(liveClassRepo: liveClassRepo),
                    const SizedBox(height: 24),

                    // My Classes & Courses
                    _SectionHeader(title: 'My Classes & Courses', onSeeAll: () => context.go(RouteNames.traineeCourses)),
                    const SizedBox(height: 12),
                    _ContinueLearningSection(user: user, courseRepo: courseRepo),
                    const SizedBox(height: 24),

                    // Quick Learning Resources
                    const _SectionHeader(title: 'Learning Resources'),
                    const SizedBox(height: 12),
                    const _QuickActionsGrid(),
                    const SizedBox(height: 24),

                    // Announcements
                    _SectionHeader(title: 'Announcements', onSeeAll: () => context.go(RouteNames.announcements)),
                    const SizedBox(height: 12),
                    _AnnouncementsSection(resourceRepo: resourceRepo),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, UserModel? user) {
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.name ?? 'Trainee',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (user?.studentId != null && user!.studentId!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Trainee ID: ${user.studentId}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.traineeProfile),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                          child: user?.photoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 24) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.go(RouteNames.announcements),
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        ),
      ],
    );
  }
}

// ── Trainee Live Classes Section ──────────────────────────────────────────────

class _TraineeLiveClassesSection extends StatelessWidget {
  final LiveClassRepository liveClassRepo;
  const _TraineeLiveClassesSection({required this.liveClassRepo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LiveClassModel>>(
      stream: liveClassRepo.getUpcomingLiveClasses(),
      builder: (context, snapshot) {
        final classes = snapshot.data ?? [];
        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.video_camera_back_outlined, color: AppColors.textSecondary, size: 20),
                SizedBox(width: 10),
                Text(
                  'No upcoming live sessions scheduled.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return Column(
          children: classes.map((item) => _LiveClassItemCard(liveClass: item)).toList(),
        );
      },
    );
  }
}

class _LiveClassItemCard extends StatelessWidget {
  final LiveClassModel liveClass;
  const _LiveClassItemCard({required this.liveClass});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.live_tv, color: Colors.red, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveClass.topic,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Subject: ${liveClass.subject}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Join Buttons
          Row(
            children: [
              if (liveClass.hasGoogleMeet)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(liveClass.googleMeetUrl!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA4335),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.video_camera_front, size: 16),
                    label: const Text('Join Google Meet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (liveClass.hasGoogleMeet && liveClass.hasZoom) const SizedBox(width: 8),
              if (liveClass.hasZoom)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(liveClass.zoomUrl!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D8CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.video_call, size: 16),
                    label: const Text('Join Zoom', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UserModel? user;
  final UserRepository userRepo;

  const _StatsRow({required this.user, required this.userRepo});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<List<ProgressModel>>(
      stream: userRepo.getAllProgress(user!.uid),
      builder: (context, snapshot) {
        final progresses = snapshot.data ?? [];
        final enrolled = progresses.length;
        final completed = progresses.where((p) => p.overallProgress >= 1.0).length;
        final avgProgress = progresses.isEmpty
            ? 0.0
            : progresses.map((p) => p.overallProgress).reduce((a, b) => a + b) /
                progresses.length;

        return Row(
          children: [
            _StatCard(
              icon: Icons.book_outlined,
              value: '$enrolled',
              label: 'Enrolled',
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: Icons.check_circle_outline,
              value: '$completed',
              label: 'Completed',
              color: const Color(0xFF00695C),
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: Icons.trending_up,
              value: '${(avgProgress * 100).toInt()}%',
              label: 'Progress',
              color: AppColors.accentDark,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Continue Learning ─────────────────────────────────────────────────────────

class _ContinueLearningSection extends StatelessWidget {
  final UserModel? user;
  final CourseRepository courseRepo;

  const _ContinueLearningSection({required this.user, required this.courseRepo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CourseModel>>(
      stream: courseRepo.getPublishedCourses(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return Container(
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No courses available yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length.clamp(0, 5),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final course = courses[index];
              return _CourseTile(course: course);
            },
          ),
        );
      },
    );
  }
}

class _CourseTile extends StatelessWidget {
  final CourseModel course;
  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final colorIndex = course.categoryId?.hashCode.abs() ?? 0;
    final color = AppColors.categoryColors[colorIndex % AppColors.categoryColors.length];

    return GestureDetector(
      onTap: () => context.go('/trainee/courses/${course.id}'),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book, color: Colors.white, size: 20),
            const Spacer(),
            Text(
              course.title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              course.categoryName ?? 'General',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions Grid ────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final _actions = const [
    (Icons.library_books_outlined, 'Digital Forestry Library', RouteNames.library, AppColors.primary),
    (Icons.smart_toy_outlined, 'AI Assistant', RouteNames.aiAssistant, Color(0xFF1565C0)),
    (Icons.location_on_outlined, 'Attendance', RouteNames.traineeAttendance, Color(0xFF2E7D32)),
    (Icons.map_outlined, 'Academy Map', RouteNames.academyMap, Color(0xFF00695C)),
    (Icons.quiz_outlined, 'Quizzes', RouteNames.quizList, Color(0xFFE65100)),
    (Icons.trending_up, 'Progress', RouteNames.progress, Color(0xFFC62828)),
  ];

  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _actions.length,
      itemBuilder: (context, index) {
        final (icon, label, route, color) = _actions[index];
        return GestureDetector(
          onTap: () => context.go(route),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Announcements Section ─────────────────────────────────────────────────────

class _AnnouncementsSection extends StatelessWidget {
  final ResourceRepository resourceRepo;
  const _AnnouncementsSection({required this.resourceRepo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnnouncementModel>>(
      stream: resourceRepo.getAnnouncements(audience: 'trainee'),
      builder: (context, snapshot) {
        final announcements = (snapshot.data ?? []).take(3).toList();
        if (announcements.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('No announcements.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return Column(
          children: announcements.map((ann) => _AnnouncementTile(announcement: ann)).toList(),
        );
      },
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementTile({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(announcement.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(announcement.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See all', style: TextStyle(fontSize: 13, color: AppColors.primary)),
          ),
      ],
    );
  }
}
