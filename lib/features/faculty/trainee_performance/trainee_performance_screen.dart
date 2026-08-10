import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TraineePerformanceScreen extends StatelessWidget {
  const TraineePerformanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('TraineePerformanceScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('TraineePerformanceScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
