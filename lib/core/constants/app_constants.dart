// ─────────────────────────────────────────────────────────────────────────────
// lib/core/constants/app_constants.dart
// Central constants for the entire app.
// ─────────────────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // App Identity
  static const String appName = 'AP Forest LMS E-Center';
  static const String appSubtitle = 'Smart Digital Learning & Training Management Platform for Officer Trainees';
  static const String appTagline = 'Learn. Train. Conserve.';

  // Academy Info (configurable from Firestore; these are fallback defaults)
  static const String academyName = 'A.P. State Forest Academy';
  static const String academyAddress =
      'R.F.R. Complex, Lalacheruvu\nRajamahendravaram – 533106\nAndhra Pradesh, India';
  static const String academyPhone = '+91-883-XXXXXXX'; // configure from Firestore
  static const String academyEmail = 'apforestacademy@ap.gov.in'; // configure from Firestore
  static const String academyWebsite = 'https://apforestacademy.gov.in';

  // Academy GPS (rough area; exact coords must be set by Admin in Firestore)
  // Rajamahendravaram area coordinates — Admin must verify & update via Settings
  static const double academyDefaultLat = 17.0053;
  static const double academyDefaultLng = 81.7800;
  static const double defaultGeofenceRadius = 200.0; // meters

  // AI / Backend
  static const String envBackendUrl = 'BACKEND_BASE_URL';
  static const String backendFallbackUrl = 'http://10.0.2.2:8000';

  // AI Endpoints
  static const String generateQuizEndpoint = '/generate-quiz';
  static const String aiAssistantEndpoint = '/ai-assistant';
  static const String healthEndpoint = '/health';

  // Firestore Collection paths
  static const String colUsers = 'users';
  static const String colCourses = 'courses';
  static const String colModules = 'modules';
  static const String colCategories = 'categories';
  static const String colResources = 'resources';
  static const String colQuizzes = 'quizzes';
  static const String colQuestions = 'questions';
  static const String colQuizAttempts = 'quizAttempts';
  static const String colProgress = 'progress';
  static const String colAnnouncements = 'announcements';
  static const String colTrainingPrograms = 'trainingPrograms';
  static const String colTimetable = 'timetable';
  static const String colBookmarks = 'bookmarks';
  static const String colAcademySettings = 'academySettings';
  static const String colAiJobs = 'aiJobs';
  static const String colNotifications = 'notifications';
  static const String colFacultyAssignments = 'facultyAssignments';

  // Firestore Document paths
  static const String docAcademyLocation = 'location';
  static const String docAcademyInfo = 'info';
  static const String docAppConfig = 'config';

  // Storage Paths
  static const String storageLogos = 'logos/';
  static const String storageProfilePhotos = 'profilePhotos/';
  static const String storageCourseThumbnails = 'courseThumbnails/';
  static const String storageResourcePdfs = 'resources/pdfs/';
  static const String storageResourceImages = 'resources/images/';
  static const String storageVideos = 'videos/';
  static const String storageFieldResources = 'fieldResources/';
  static const String storageQuizSourcePdfs = 'quizSourcePdfs/';

  // Role values (must match Firestore user.role field)
  static const String roleTrainee = 'trainee';
  static const String roleFaculty = 'faculty';
  static const String roleAdmin = 'admin';

  // AI Job statuses
  static const String jobQueued = 'queued';
  static const String jobProcessing = 'processing';
  static const String jobCompleted = 'completed';
  static const String jobFailed = 'failed';

  // Quiz statuses
  static const String quizDraft = 'draft';
  static const String quizAiReview = 'ai_review';
  static const String quizPublished = 'published';

  // User statuses
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';

  // Announcement priorities
  static const String priorityNormal = 'normal';
  static const String priorityImportant = 'important';
  static const String priorityUrgent = 'urgent';

  // Asset paths
  static const String logoAsset = 'assets/images/academy_logo.png';
  static const String placeholderLogoAsset = 'assets/images/logo_placeholder.png';
  static const String splashVideoAsset = 'assets/videos/splash_video.mp4';

  // Map tile URLs
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String esriSatelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String esriTopoTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
  // OpenStreetMap Humanitarian — good for terrain and forest areas in India
  static const String osmHumanitarianTileUrl =
      'https://tile-{s}.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  // Pagination
  static const int pageSize = 20;
  static const int maxPdfSizeMb = 20;

  // AI limits
  static const int maxQuestionsToGenerate = 10;
  static const int minQuestionsRequired = 3;

  // AI disclaimer
  static const String aiDisclaimer =
      'AI-generated responses should be verified against official training '
      'material and faculty guidance. This assistant is for learning support only.';
}
