// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trainee/dashboard/trainee_dashboard_screen.dart
// Shell screen with bottom navigation for trainees.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../models/course_model.dart';
import '../../../models/other_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/course_repository.dart';
import '../../../repositories/resource_repository.dart';
import '../../../repositories/user_repository.dart';

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
              label: 'Courses',
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

                    // Continue Learning
                    _SectionHeader(title: 'Continue Learning', onSeeAll: () => context.go(RouteNames.traineeCourses)),
                    const SizedBox(height: 12),
                    _ContinueLearningSection(user: user, courseRepo: courseRepo),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const _SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _QuickActionsGrid(),
                    const SizedBox(height: 24),

                    // Announcements
                    _SectionHeader(title: 'Announcements', onSeeAll: () => context.go(RouteNames.announcements)),
                    const SizedBox(height: 12),
                    _AnnouncementsSection(resourceRepo: resourceRepo),
                    const SizedBox(height: 24),

                    // Upcoming Training
                    _SectionHeader(title: 'Upcoming Schedule', onSeeAll: () => context.go(RouteNames.timetable)),
                    const SizedBox(height: 12),
                    _UpcomingScheduleSection(userRepo: userRepo),
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
      expandedHeight: 140,
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
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.name.split(' ').first ?? 'Trainee',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Profile picture
                      GestureDetector(
                        onTap: () => context.go(RouteNames.traineeProfile),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage: user?.photoUrl != null
                              ? NetworkImage(user!.photoUrl!)
                              : null,
                          child: user?.photoUrl == null
                              ? const Icon(Icons.person, color: Colors.white, size: 24)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        AppConstants.academyName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
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
        IconButton(
          onPressed: () => context.go(RouteNames.aiAssistant),
          icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        ),
      ],
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton();
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return _buildEmpty();
        }
        return SizedBox(
          height: 160,
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

  Widget _buildSkeleton() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 220,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 100,
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
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 18),
            ),
            const Spacer(),
            Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              course.categoryName ?? 'General',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar placeholder (needs progress data)
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: 0.3,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
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
    (Icons.map_outlined, 'Academy Map', RouteNames.academyMap, AppColors.primary),
    (Icons.smart_toy_outlined, 'AI Assistant', RouteNames.aiAssistant, Color(0xFF1565C0)),
    (Icons.schedule_outlined, 'Timetable', RouteNames.timetable, Color(0xFF00695C)),
    (Icons.bookmark_outline, 'Bookmarks', RouteNames.bookmarks, Color(0xFFE65100)),
    (Icons.info_outline, 'Academy', RouteNames.academyInfo, Color(0xFF4A148C)),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
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

// ── Announcements Preview ─────────────────────────────────────────────────────

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
            child: const Text(
              'No announcements.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Column(
          children: announcements
              .map((ann) => _AnnouncementTile(announcement: ann))
              .toList(),
        );
      },
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementTile({required this.announcement});

  Color get _priorityColor {
    switch (announcement.priority) {
      case 'urgent': return AppColors.priorityUrgent;
      case 'important': return AppColors.priorityImportant;
      default: return AppColors.priorityNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: _priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  announcement.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Schedule ─────────────────────────────────────────────────────────

class _UpcomingScheduleSection extends StatelessWidget {
  final UserRepository userRepo;
  const _UpcomingScheduleSection({required this.userRepo});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    return StreamBuilder<List<TimetableModel>>(
      stream: userRepo.getTimetable(from: now, to: weekEnd),
      builder: (context, snapshot) {
        final entries = (snapshot.data ?? []).take(3).toList();
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No upcoming sessions this week.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Column(
          children: entries.map((e) => _ScheduleTile(entry: e)).toList(),
        );
      },
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final TimetableModel entry;
  const _ScheduleTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '${entry.date.day}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _monthShort(entry.date.month),
                  style: const TextStyle(fontSize: 10, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.startTime} – ${entry.endTime}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (entry.location != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.place_outlined, size: 12, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Text(
                        entry.location!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.type,
              style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
