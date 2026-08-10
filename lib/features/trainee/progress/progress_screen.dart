import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('ProgressScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('ProgressScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
