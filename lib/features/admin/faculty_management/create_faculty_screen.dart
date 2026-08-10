import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CreateFacultyScreen extends StatelessWidget {
  const CreateFacultyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('CreateFacultyScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('CreateFacultyScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
