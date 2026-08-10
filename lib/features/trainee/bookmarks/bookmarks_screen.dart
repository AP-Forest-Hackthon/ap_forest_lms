import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('BookmarksScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('BookmarksScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
