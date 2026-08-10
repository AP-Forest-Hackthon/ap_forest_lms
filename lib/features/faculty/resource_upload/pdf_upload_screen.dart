import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PdfUploadScreen extends StatelessWidget {
  const PdfUploadScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('PdfUploadScreen'.replaceAll('Screen', '')), backgroundColor: AppColors.primary),
      body: const Center(child: Text('PdfUploadScreen - Coming Soon', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
