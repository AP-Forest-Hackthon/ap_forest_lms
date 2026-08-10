// ─────────────────────────────────────────────────────────────────────────────
// lib/features/auth/splash/splash_screen.dart
// Professional splash screen with academy branding.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _textController.forward();
      });
    });
  }

  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.status == AuthStatus.authenticated && auth.user != null) {
        // Already signed in — router guard handles redirect
        context.go(RouteNames.traineeDashboard);
      } else {
        context.go(RouteNames.login);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo ────────────────────────────────────────────
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (_, child) => Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(opacity: _logoOpacity.value, child: child),
                        ),
                        child: _buildLogo(),
                      ),

                      const SizedBox(height: 32),

                      // ── Text ────────────────────────────────────────────
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (_, child) => SlideTransition(
                          position: _textSlide,
                          child: Opacity(opacity: _textOpacity.value, child: child),
                        ),
                        child: _buildText(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Loading Indicator ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          AppConstants.logoAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildPlaceholderLogo(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, color: Colors.white, size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildText() {
    return Column(
      children: [
        const Text(
          AppConstants.appName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          width: 48,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppConstants.appTagline,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          AppConstants.academyName,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
