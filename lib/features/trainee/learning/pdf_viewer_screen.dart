import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  const PdfViewerScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.primary),
      body: Center(child: Text('PDF Viewer: $url', style: const TextStyle(color: AppColors.textSecondary))),
    );
  }
}
