import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('CoursesScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('CoursesScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
