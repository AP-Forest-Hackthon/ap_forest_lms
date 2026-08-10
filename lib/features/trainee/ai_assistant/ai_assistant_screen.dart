import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('AiAssistantScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('AiAssistantScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
