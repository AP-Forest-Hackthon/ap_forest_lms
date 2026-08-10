import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FacultyProfileScreen extends StatelessWidget {
  const FacultyProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('FacultyProfileScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('FacultyProfileScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
