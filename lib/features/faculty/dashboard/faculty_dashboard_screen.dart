import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';

class FacultyDashboardScreen extends StatefulWidget {
  final Widget child;
  const FacultyDashboardScreen({super.key, required this.child});
  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  int _index = 0;
  final _tabs = [RouteNames.facultyDashboard, RouteNames.facultyCourses, RouteNames.aiQuizGenerator, RouteNames.traineePerformance, RouteNames.facultyProfile];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) { setState(() => _index = i); context.go(_tabs[i]); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'AI Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Performance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FacultyHomeTab extends StatelessWidget {
  const FacultyHomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Faculty Dashboard'), backgroundColor: AppColors.primary),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ActionCard(icon: Icons.auto_awesome, title: 'Generate AI Quiz', subtitle: 'Upload PDF → AI generates MCQs', route: RouteNames.aiQuizGenerator, color: AppColors.primary),
          const SizedBox(height: 12),
          _ActionCard(icon: Icons.upload_file, title: 'Upload Resource', subtitle: 'Share PDFs with trainees', route: RouteNames.pdfUpload, color: const Color(0xFF1565C0)),
          const SizedBox(height: 12),
          _ActionCard(icon: Icons.quiz_outlined, title: 'Manage Quizzes', subtitle: 'Review and publish quizzes', route: RouteNames.facultyCourses, color: const Color(0xFF00695C)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.route, required this.color});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ]),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
