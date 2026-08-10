// ─────────────────────────────────────────────────────────────────────────────
// lib/main.dart
// Forest Academy E-Center — Application Entry Point
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase Initialization ────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // ── Load .env for backend URL ──────────────────────────────────────────────
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env may not be present in production builds
  }

  // ── Lock to portrait (mobile app) ─────────────────────────────────────────
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  // ── Status Bar Styling ─────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ApForestLmsApp());
}

class ApForestLmsApp extends StatelessWidget {
  const ApForestLmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late AppRouter _appRouter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    _appRouter = AppRouter(authProvider: authProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth provider so router refreshes on auth state changes
    context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'AP Forest LMS E-Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.router,
    );
  }
}
