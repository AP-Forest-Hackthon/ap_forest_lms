import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AcademyInfoScreen extends StatelessWidget {
  const AcademyInfoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('AcademyInfoScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('AcademyInfoScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
