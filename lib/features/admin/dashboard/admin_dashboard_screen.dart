import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/route_names.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Widget child;
  const AdminDashboardScreen({super.key, required this.child});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _index = 0;
  final _tabs = [RouteNames.adminDashboard, RouteNames.adminFacultyList, RouteNames.adminTraineeList, RouteNames.analytics, RouteNames.adminAnnouncements];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) { setState(() => _index = i); context.go(_tabs[i]); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outlined), activeIcon: Icon(Icons.people), label: 'Faculty'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Trainees'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Announce'),
        ],
      ),
    );
  }
}

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: AppColors.primary),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AdminCard(icon: Icons.people, title: 'Manage Faculty', route: RouteNames.adminFacultyList),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.school, title: 'Manage Trainees', route: RouteNames.adminTraineeList),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.category, title: 'Manage Categories', route: RouteNames.categoryList),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.settings, title: 'Academy Settings', route: RouteNames.academyManagement),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.campaign, title: 'Announcements', route: RouteNames.adminAnnouncements),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  const _AdminCard({required this.icon, required this.title, required this.route});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppColors.surface,
    );
  }
}
