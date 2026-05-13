import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/controllers/settings_controller.dart';
import 'package:cycle_fit/core/services/firebase/firebase_initializer.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/core/theme/app_theme.dart';
import 'package:cycle_fit/core/auth/auth_guard.dart';
import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/views/auth/login_page.dart';
import 'package:cycle_fit/views/auth/register_page.dart';
import 'package:cycle_fit/views/settings/settings_page.dart';
import 'package:cycle_fit/views/settings/notifications_settings_page.dart';
import 'package:cycle_fit/views/settings/privacy_security_page.dart';
import 'package:cycle_fit/views/settings/help_support_page.dart';
import 'package:cycle_fit/views/settings/about_page.dart';
import 'package:cycle_fit/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  final _settingsController = SettingsController();

  @override
  void initState() {
    super.initState();
    _controller = AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _controller),
        ChangeNotifierProvider(create: (_) => _settingsController),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CycleFit',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
locale: settings.locale,
             supportedLocales: const [
               Locale('en'),
               Locale('es'),
             ],
             localizationsDelegates: [
               AppLocalizationDelegate(),
               GlobalMaterialLocalizations.delegate,
               GlobalWidgetsLocalizations.delegate,
               GlobalCupertinoLocalizations.delegate,
             ],
            home: StreamBuilder(
              stream: _authService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return FutureBuilder<bool>(
                    future: _authService.hasValidSessionToken(),
                    builder: (context, tokenSnapshot) {
                      if (tokenSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (tokenSnapshot.data == true) {
                        return DashboardPage(controller: _controller);
                      }

                      return const LoginPage();
                    },
                  );
                }

                return const LoginPage();
              },
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/register-google-onboarding': (context) =>
                  const RegisterPage(googleOnboarding: true),
              '/dashboard': (context) =>
                  AuthGuard(child: DashboardPage(controller: _controller)),
              '/notifications': (context) => const NotificationsSettingsPage(),
              '/privacy': (context) => const PrivacySecurityPage(),
              '/help': (context) => const HelpSupportPage(),
              '/settings': (context) => const SettingsPage(),
              '/about': (context) => const AboutPage(),
            },
          );
        },
      ),
    );
  }
}