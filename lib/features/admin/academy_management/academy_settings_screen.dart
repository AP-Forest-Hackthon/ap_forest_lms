import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AcademySettingsScreen extends StatelessWidget {
  const AcademySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('AcademySettingsScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('AcademySettingsScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
