import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ModuleLearningScreen extends StatelessWidget {
  final String courseId;
  final String moduleId;
  const ModuleLearningScreen({super.key, required this.courseId, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learning Module'), backgroundColor: AppColors.primary),
      body: Center(child: Text('Module: $moduleId', style: const TextStyle(color: AppColors.textSecondary))),
    );
  }
}
