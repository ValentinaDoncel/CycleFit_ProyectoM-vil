import 'dart:async';

import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/services/firebase/firebase_initializer.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/core/theme/app_theme.dart';
import 'package:cycle_fit/views/auth/login_page.dart';
import 'package:cycle_fit/views/auth/register_page.dart';
import 'package:cycle_fit/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _authService = AuthService();

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _controller),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CycleFit',
        theme: AppTheme.lightTheme,
        // Determinar la ruta inicial según si hay usuario autenticado
        home: StreamBuilder(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            // Mientras se verifica el estado de autenticación
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Si hay usuario autenticado, mostrar el dashboard
            if (snapshot.hasData && snapshot.data != null) {
              return DashboardPage(controller: _controller);
            }

            // Si no hay usuario, mostrar login
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => DashboardPage(controller: _controller),
        },
      ),
    );
  }
}
