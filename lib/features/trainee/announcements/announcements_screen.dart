import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('AnnouncementsScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('AnnouncementsScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
