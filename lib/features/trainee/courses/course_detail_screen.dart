import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Course Details'), backgroundColor: AppColors.primary),
      body: Center(
        child: Text(
          'Course ID: $courseId\n(Course overview & modules list)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
