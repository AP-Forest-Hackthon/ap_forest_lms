import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FacultyListScreen extends StatelessWidget {
  const FacultyListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('FacultyListScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('FacultyListScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
