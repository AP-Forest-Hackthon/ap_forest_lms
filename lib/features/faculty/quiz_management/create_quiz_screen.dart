import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CreateQuizScreen extends StatelessWidget {
  const CreateQuizScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('CreateQuizScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('CreateQuizScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
