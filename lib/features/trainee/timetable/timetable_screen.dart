import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('TimetableScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('TimetableScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
