import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FacultyCoursesScreen extends StatelessWidget {
  const FacultyCoursesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('FacultyCoursesScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('FacultyCoursesScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
