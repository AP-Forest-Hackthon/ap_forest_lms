import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TraineeProfileScreen extends StatelessWidget {
  const TraineeProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('TraineeProfileScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('TraineeProfileScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
