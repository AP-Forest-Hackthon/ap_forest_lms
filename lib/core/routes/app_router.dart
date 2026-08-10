// ─────────────────────────────────────────────────────────────────────────────
// lib/core/routes/app_router.dart
// GoRouter configuration with role-aware redirects.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/splash/splash_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/faculty_register_screen.dart';
import '../../features/auth/register/student_register_screen.dart';

// Trainee
import '../../features/trainee/dashboard/trainee_dashboard_screen.dart';
import '../../features/trainee/courses/courses_screen.dart';
import '../../features/trainee/courses/course_detail_screen.dart';
import '../../features/trainee/learning/module_learning_screen.dart';
import '../../features/trainee/learning/pdf_viewer_screen.dart';
import '../../features/trainee/library/library_screen.dart';
import '../../features/trainee/quizzes/quiz_list_screen.dart';
import '../../features/trainee/quizzes/quiz_attempt_screen.dart';
import '../../features/trainee/quizzes/quiz_result_screen.dart';
import '../../features/trainee/announcements/announcements_screen.dart';
import '../../features/trainee/timetable/timetable_screen.dart';
import '../../features/trainee/academy/academy_info_screen.dart';
import '../../features/trainee/map/academy_map_screen.dart';
import '../../features/trainee/profile/trainee_profile_screen.dart';
import '../../features/trainee/ai_assistant/ai_assistant_screen.dart';
import '../../features/trainee/bookmarks/bookmarks_screen.dart';
import '../../features/trainee/progress/progress_screen.dart';

// Faculty
import '../../features/faculty/dashboard/faculty_dashboard_screen.dart';
import '../../features/faculty/courses/faculty_courses_screen.dart';
import '../../features/faculty/resource_upload/pdf_upload_screen.dart';
import '../../features/faculty/ai_quiz_generator/ai_quiz_generator_screen.dart';
import '../../features/faculty/quiz_management/quiz_review_screen.dart';
import '../../features/faculty/quiz_management/create_quiz_screen.dart';
import '../../features/faculty/trainee_performance/trainee_performance_screen.dart';
import '../../features/faculty/profile/faculty_profile_screen.dart';

// Admin
import '../../features/admin/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/faculty_management/faculty_list_screen.dart';
import '../../features/admin/faculty_management/create_faculty_screen.dart';
import '../../features/admin/trainee_management/trainee_list_screen.dart';
import '../../features/admin/category_management/category_list_screen.dart';
import '../../features/admin/academy_management/academy_settings_screen.dart';
import '../../features/admin/analytics/analytics_screen.dart';
import '../../features/admin/announcement_management/admin_announcement_screen.dart';

import 'route_names.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authProvider,
    redirect: _guard,
    routes: _routes,
  );

  // ── Auth Guard ─────────────────────────────────────────────────────────────

  String? _guard(BuildContext context, GoRouterState state) {
    final authStatus = authProvider.status;
    final user = authProvider.user;
    final location = state.uri.toString();

    // Still loading — stay on splash
    if (authStatus == AuthStatus.unknown) {
      return location == RouteNames.splash ? null : RouteNames.splash;
    }

    // Not authenticated → go to login unless on register pages
    if (authStatus == AuthStatus.unauthenticated) {
      if (location == RouteNames.splash ||
          location == RouteNames.login ||
          location == RouteNames.registerFaculty ||
          location == RouteNames.registerStudent) {
        return null;
      }
      return RouteNames.login;
    }

    // Authenticated → redirect splash/login to appropriate dashboard
    if (authStatus == AuthStatus.authenticated && user != null) {
      if (location == RouteNames.splash ||
          location == RouteNames.login ||
          location == RouteNames.registerFaculty ||
          location == RouteNames.registerStudent) {
        switch (user.role) {
          case UserRole.trainee:
            return RouteNames.traineeDashboard;
          case UserRole.faculty:
            return RouteNames.facultyDashboard;
          case UserRole.admin:
            return RouteNames.adminDashboard;
        }
      }

      // Role-based access control
      if (location.startsWith('/faculty') && !user.isFaculty && !user.isAdmin) {
        return RouteNames.traineeDashboard;
      }
      if (location.startsWith('/admin') && !user.isAdmin) {
        if (user.isFaculty) return RouteNames.facultyDashboard;
        return RouteNames.traineeDashboard;
      }
      if (location.startsWith('/trainee') && user.isFaculty) {
        return RouteNames.facultyDashboard;
      }
      if (location.startsWith('/trainee') && user.isAdmin) {
        return RouteNames.adminDashboard;
      }
    }

    return null;
  }

  // ── Routes ─────────────────────────────────────────────────────────────────

  List<RouteBase> get _routes => [
    GoRoute(
      path: RouteNames.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.registerFaculty,
      builder: (_, __) => const FacultyRegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.registerStudent,
      builder: (_, __) => const StudentRegisterScreen(),
    ),

    // ── Trainee Shell ────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => TraineeDashboardScreen(child: child),
      routes: [
        GoRoute(path: RouteNames.traineeDashboard, builder: (_, __) => const TraineeHomeTab()),
        GoRoute(path: RouteNames.traineeCourses, builder: (_, __) => const CoursesScreen()),
        GoRoute(
          path: RouteNames.courseDetail,
          builder: (_, state) => CourseDetailScreen(courseId: state.pathParameters['courseId']!),
        ),
        GoRoute(
          path: RouteNames.moduleDetail,
          builder: (_, state) => ModuleLearningScreen(
            courseId: state.pathParameters['courseId']!,
            moduleId: state.pathParameters['moduleId']!,
          ),
        ),
        GoRoute(path: RouteNames.library, builder: (_, __) => const LibraryScreen()),
        GoRoute(path: RouteNames.quizList, builder: (_, __) => const QuizListScreen()),
        GoRoute(
          path: RouteNames.quizAttempt,
          builder: (_, state) => QuizAttemptScreen(quizId: state.pathParameters['quizId']!),
        ),
        GoRoute(
          path: RouteNames.quizResult,
          builder: (_, state) => QuizResultScreen(
            quizId: state.pathParameters['quizId']!,
            extra: state.extra,
          ),
        ),
        GoRoute(path: RouteNames.progress, builder: (_, __) => const ProgressScreen()),
        GoRoute(path: RouteNames.announcements, builder: (_, __) => const AnnouncementsScreen()),
        GoRoute(path: RouteNames.timetable, builder: (_, __) => const TimetableScreen()),
        GoRoute(path: RouteNames.academyInfo, builder: (_, __) => const AcademyInfoScreen()),
        GoRoute(path: RouteNames.academyMap, builder: (_, __) => const AcademyMapScreen()),
        GoRoute(path: RouteNames.traineeProfile, builder: (_, __) => const TraineeProfileScreen()),
        GoRoute(path: RouteNames.aiAssistant, builder: (_, __) => const AiAssistantScreen()),
        GoRoute(path: RouteNames.bookmarks, builder: (_, __) => const BookmarksScreen()),
        GoRoute(
          path: RouteNames.pdfViewer,
          builder: (_, state) {
            final extra = state.extra as Map<String, String>?;
            return PdfViewerScreen(
              url: extra?['url'] ?? '',
              title: extra?['title'] ?? 'Document',
            );
          },
        ),
      ],
    ),

    // ── Faculty Shell ────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => FacultyDashboardScreen(child: child),
      routes: [
        GoRoute(path: RouteNames.facultyDashboard, builder: (_, __) => const FacultyHomeTab()),
        GoRoute(path: RouteNames.facultyCourses, builder: (_, __) => const FacultyCoursesScreen()),
        GoRoute(path: RouteNames.pdfUpload, builder: (_, __) => const PdfUploadScreen()),
        GoRoute(path: RouteNames.aiQuizGenerator, builder: (_, __) => const AiQuizGeneratorScreen()),
        GoRoute(
          path: RouteNames.quizReview,
          builder: (_, state) => QuizReviewScreen(quizId: state.pathParameters['quizId']!),
        ),
        GoRoute(path: RouteNames.createQuiz, builder: (_, __) => const CreateQuizScreen()),
        GoRoute(path: RouteNames.traineePerformance, builder: (_, __) => const TraineePerformanceScreen()),
        GoRoute(path: RouteNames.facultyProfile, builder: (_, __) => const FacultyProfileScreen()),
      ],
    ),

    // ── Admin Shell ──────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AdminDashboardScreen(child: child),
      routes: [
        GoRoute(path: RouteNames.adminDashboard, builder: (_, __) => const AdminHomeTab()),
        GoRoute(path: RouteNames.adminFacultyList, builder: (_, __) => const FacultyListScreen()),
        GoRoute(path: RouteNames.createFaculty, builder: (_, __) => const CreateFacultyScreen()),
        GoRoute(path: RouteNames.adminTraineeList, builder: (_, __) => const TraineeListScreen()),
        GoRoute(path: RouteNames.categoryList, builder: (_, __) => const CategoryListScreen()),
        GoRoute(path: RouteNames.academyManagement, builder: (_, __) => const AcademySettingsScreen()),
        GoRoute(path: RouteNames.analytics, builder: (_, __) => const AnalyticsScreen()),
        GoRoute(path: RouteNames.adminAnnouncements, builder: (_, __) => const AdminAnnouncementScreen()),
      ],
    ),
  ];
}
