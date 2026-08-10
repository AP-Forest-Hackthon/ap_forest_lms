import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TraineeListScreen extends StatelessWidget {
  const TraineeListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('TraineeListScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('TraineeListScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
