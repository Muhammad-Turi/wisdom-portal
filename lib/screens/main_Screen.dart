import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/providers/class_provider.dart';
import 'package:wisdom_portal_1/providers/purchase_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/providers/teacher_provider.dart';
import 'package:wisdom_portal_1/screens/classes_screen.dart';
import 'package:wisdom_portal_1/screens/dashboard_screen.dart';
import 'package:wisdom_portal_1/screens/fee_screen.dart';
import 'package:wisdom_portal_1/screens/teacher_screen.dart';
import 'package:wisdom_portal_1/widgets/exit_confirm_scope.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const double _wideBreakpoint = 800;

  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    DashboardScreen(),
    ClassesScreen(),
    TeacherScreen(),
    FeeScreen(),
  ];

  final List<bool> _visited = [true, false, false, false];

  static const _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(icon: Icon(Icons.school), label: Text('Classes')),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Teacher')),
    NavigationRailDestination(
      icon: Icon(Icons.book_online_outlined),
      label: Text('Fee'),
    ),
  ];

  static const _bottomItems = [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Classes'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Teacher'),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_online_outlined),
      label: 'Fee',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StudentProvider>().listenToStudents();
      context.read<PurchaseProvider>().listenToPurchases();
      context.read<TeacherProvider>().listenToTeachers();
      context.read<ClassProvider>().listenToClasses();
    });
  }

  void _onSelect(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      _visited[index] = true;
    });
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: List.generate(
        _screens.length,
        (i) => _visited[i] ? _screens[i] : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > _wideBreakpoint;

    return ExitConfirmScope(
      child: Scaffold(
        body: isWide
            ? Row(
                children: [
                  NavigationRail(
                    minWidth: 90,
                    onDestinationSelected: _onSelect,
                    labelType: NavigationRailLabelType.all,
                    selectedIndex: _selectedIndex,
                    destinations: _railDestinations,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildBody()),
                ],
              )
            : _buildBody(),
        bottomNavigationBar: isWide
            ? null
            : BottomNavigationBar(
                selectedItemColor: Colors.purple.shade400,
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onSelect,
                items: _bottomItems,
              ),
      ),
    );
  }
}
