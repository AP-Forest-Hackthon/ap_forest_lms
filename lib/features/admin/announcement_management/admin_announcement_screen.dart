import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdminAnnouncementScreen extends StatelessWidget {
  const AdminAnnouncementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('AdminAnnouncementScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('AdminAnnouncementScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
