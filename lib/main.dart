import 'dart:async';

import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/services/firebase/firebase_initializer.dart';
import 'package:cycle_fit/core/theme/app_theme.dart';
import 'package:cycle_fit/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  runApp(const CycleFitApp());
}

class CycleFitApp extends StatefulWidget {
  const CycleFitApp({super.key});

  @override
  State<CycleFitApp> createState() => _CycleFitAppState();
}

class _CycleFitAppState extends State<CycleFitApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CycleFit',
      theme: AppTheme.lightTheme,
      home: DashboardPage(controller: _controller),
    );
  }
}
