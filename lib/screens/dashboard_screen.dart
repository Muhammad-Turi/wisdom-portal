import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/providers/auth_provider.dart';
import 'package:wisdom_portal_1/providers/class_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/providers/teacher_provider.dart';
import 'package:wisdom_portal_1/screens/graduated_students_screen.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';
import 'package:wisdom_portal_1/widgets/stats_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const _DashboardAppBar(),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard<StudentProvider>(
                        label: "Active Students",
                        iconBackgroundColor: Colors.lightBlue.shade100,
                        iconData: Icons.people_sharp,
                        value: (p) => p.totalStudent.toString(),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _StatCard<TeacherProvider>(
                        label: "Total Teachers",
                        iconBackgroundColor: Colors.orange.shade100,
                        iconData: Icons.person,
                        value: (p) => p.totalTeacher.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard<ClassProvider>(
                        label: "Total Class",
                        iconBackgroundColor: Colors.green.shade100,
                        iconData: Icons.book_online,
                        value: (p) => p.totalClasses.toString(),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _StatCard<StudentProvider>(
                        label: "Graduated",
                        iconBackgroundColor: Colors.purple.shade100,
                        iconData: Icons.school,
                        value: (p) => p.graduatedCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GraduatedStudentsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _FeeOverview(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return AppBar(
      toolbarHeight: 70,
      actions: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("${now.day} - ${now.month} - ${now.year}"),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: "Logout",
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
      title: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.orange.shade500,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Wisdom Academic Center",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  "Admin dashboard",
                  style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard<T extends ChangeNotifier> extends StatelessWidget {
  final String label;
  final Color iconBackgroundColor;
  final IconData iconData;
  final String Function(T provider) value;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.iconBackgroundColor,
    required this.iconData,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<T, String>(
      selector: (_, provider) => value(provider),
      builder: (_, number, _) => StatsCard(
        label: label,
        cardColor: Colors.white,
        iconBackgroundColor: iconBackgroundColor,
        iconData: iconData,
        number: number,
        onTap: onTap,
      ),
    );
  }
}

class _FeeOverview extends StatelessWidget {
  const _FeeOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.cardBorder),
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fee status overview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Selector<StudentProvider, (int, int)>(
            selector: (_, p) => (p.paidStudent, p.unpaidStudent),
            builder: (_, counts, _) => Row(
              children: [
                Expanded(
                  child: _FeeBox(
                    count: counts.$1,
                    label: "Paid",
                    color: Colors.green.shade200,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FeeBox(
                    count: counts.$2,
                    label: "Unpaid",
                    color: Colors.red.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeBox extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _FeeBox({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }
}

Future<bool> _hasUnsyncedChanges() async {
  try {
    await FirebaseFirestore.instance.waitForPendingWrites().timeout(
      const Duration(seconds: 2),
    );
    return false;
  } on TimeoutException {
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _showLogoutDialog(BuildContext context) async {
  final hasUnsynced = await _hasUnsyncedChanges();
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(hasUnsynced ? "Unsynced changes" : "Logout"),
      content: Text(
        hasUnsynced
            ? "Some changes are not uploaded yet (you may be offline). "
                  "If you log out now, they may be lost, and you will not be "
                  "able to log in again until the internet returns."
            : "Are you sure you want to exit?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            hasUnsynced ? "Logout anyway" : "Logout",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await auth.logOut();
    if (auth.errorMsg != null) {
      messenger.showSnackBar(SnackBar(content: Text(auth.errorMsg!)));
    }
  }
}
