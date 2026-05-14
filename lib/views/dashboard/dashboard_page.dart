import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/views/cycle/cycle_page.dart';
import 'package:cycle_fit/views/exercise/exercise_page.dart';
import 'package:cycle_fit/views/feed/feed_page.dart';
import 'package:cycle_fit/views/home/home_page.dart';
import 'package:cycle_fit/views/profile/profile_page.dart';
import 'package:cycle_fit/views/symptoms/symptoms_page.dart';
import 'package:cycle_fit/views/tips/tips_page.dart';
import 'package:cycle_fit/widgets/app_shell.dart';
import 'package:cycle_fit/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        return AppShell(
          bottomNavigationBar: BottomNavBar(controller: controller),
          body: controller.isInitializing
              ? const Center(child: CircularProgressIndicator())
              : _bodyForTab(controller.selectedTab),
        );
      },
    );
  }

  Widget _bodyForTab(AppTab tab) {
    final controller = widget.controller;
    switch (tab) {
      case AppTab.home:
        return HomePage(controller: controller);
      case AppTab.cycle:
        return CyclePage(controller: controller);
      case AppTab.symptoms:
        return SymptomsPage(controller: controller);
      case AppTab.exercise:
        return ExercisePage(controller: controller);
      case AppTab.feed:
        return FeedPage(controller: controller);
      case AppTab.tips:
        return TipsPage(controller: controller);
      case AppTab.profile:
        return ProfilePage(controller: controller);
    }
  }
}
