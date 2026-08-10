// ─────────────────────────────────────────────────────────────────────────────
// lib/core/routes/route_names.dart
// Named route paths for GoRouter.
// ─────────────────────────────────────────────────────────────────────────────

class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';

  // Trainee
  static const String traineeDashboard = '/trainee/home';
  static const String traineeHome = '/trainee/home';
  static const String traineeCourses = '/trainee/courses';
  static const String courseDetail = '/trainee/courses/:courseId';
  static const String moduleDetail = '/trainee/courses/:courseId/modules/:moduleId';
  static const String pdfViewer = '/trainee/pdf-viewer';
  static const String videoPlayer = '/trainee/video-player';
  static const String library = '/trainee/library';
  static const String resourceDetail = '/trainee/library/:resourceId';
  static const String quizList = '/trainee/quizzes';
  static const String quizAttempt = '/trainee/quizzes/:quizId/attempt';
  static const String quizResult = '/trainee/quizzes/:quizId/result';
  static const String progress = '/trainee/progress';
  static const String announcements = '/trainee/announcements';
  static const String timetable = '/trainee/timetable';
  static const String academyInfo = '/trainee/academy';
  static const String academyMap = '/trainee/map';
  static const String traineeProfile = '/trainee/profile';
  static const String aiAssistant = '/trainee/ai-assistant';
  static const String bookmarks = '/trainee/bookmarks';

  // Faculty
  static const String facultyDashboard = '/faculty/home';
  static const String facultyCourses = '/faculty/courses';
  static const String facultyCourseDetail = '/faculty/courses/:courseId';
  static const String createCourse = '/faculty/courses/create';
  static const String createModule = '/faculty/courses/:courseId/modules/create';
  static const String resourceUpload = '/faculty/upload';
  static const String pdfUpload = '/faculty/upload/pdf';
  static const String aiQuizGenerator = '/faculty/quiz-generator';
  static const String quizReview = '/faculty/quizzes/:quizId/review';
  static const String facultyQuizList = '/faculty/quizzes';
  static const String createQuiz = '/faculty/quizzes/create';
  static const String traineePerformance = '/faculty/performance';
  static const String createAnnouncement = '/faculty/announcements/create';
  static const String facultyProfile = '/faculty/profile';

  // Admin
  static const String adminDashboard = '/admin/home';
  static const String adminFacultyList = '/admin/faculty';
  static const String createFaculty = '/admin/faculty/create';
  static const String adminTraineeList = '/admin/trainees';
  static const String adminCourseList = '/admin/courses';
  static const String categoryList = '/admin/categories';
  static const String createCategory = '/admin/categories/create';
  static const String academyManagement = '/admin/academy';
  static const String locationSettings = '/admin/academy/location';
  static const String adminAnnouncements = '/admin/announcements';
  static const String analytics = '/admin/analytics';
  static const String appSettings = '/admin/settings';
}
