import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('AnalyticsScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('AnalyticsScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
