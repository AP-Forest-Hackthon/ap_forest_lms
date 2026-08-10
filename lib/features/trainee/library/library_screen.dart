import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('LibraryScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('LibraryScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
