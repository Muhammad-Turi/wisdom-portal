import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wisdom_portal_1/firebase_options.dart';
import 'package:wisdom_portal_1/providers/auth_provider.dart';
import 'package:wisdom_portal_1/providers/purchase_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/providers/teacher_provider.dart';
import 'package:wisdom_portal_1/providers/class_provider.dart';
import 'package:wisdom_portal_1/screens/login_screen.dart';
import 'package:wisdom_portal_1/screens/main_Screen.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/screens/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      title: 'Wisdom Portal',
      minimumSize: Size(900, 600),
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    await windowManager.setPreventClose(true);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StudentProvider()),
        ChangeNotifierProvider(create: (context) => TeacherProvider()),
        ChangeNotifierProvider(create: (context) => ClassProvider()),
        ChangeNotifierProvider(create: (context) => PurchaseProvider()),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    if (isDesktop) windowManager.addListener(this);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    if (isDesktop) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Exit app"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Exit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Wisdom Portal',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.navy,
          foregroundColor: AppColor.paidBg,
          shape: RoundedRectangleBorder(),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (_showSplash || !authProvider.isInitialized) {
            return const SplashScreen();
          }
          return authProvider.isLoggedIn
              ? const MainScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
