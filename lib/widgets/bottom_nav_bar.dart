import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(AppTab.home, 'Inicio', Icons.home_outlined),
      _NavItem(AppTab.cycle, 'Ciclo', Icons.calendar_month_outlined),
      _NavItem(AppTab.symptoms, 'Síntomas', Icons.favorite_border_rounded),
      _NavItem(AppTab.exercise, 'Ejercicio', Icons.fitness_center_rounded),
      _NavItem(AppTab.feed, 'Feed', Icons.rss_feed_rounded),
      _NavItem(AppTab.tips, 'Tips', Icons.auto_awesome_outlined),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: () => controller.selectTab(item.tab),
                    child: _BottomNavItem(
                      label: item.label,
                      icon: item.icon,
                      isActive: controller.selectedTab == item.tab,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
  });

  final String label;
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final activeColor = isActive ? AppColors.surface : AppColors.muted;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: activeColor,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: activeColor, size: 24),
          ),
          const SizedBox(height: 4),
          FittedBox(child: Text(label, style: labelStyle)),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.tab, this.label, this.icon);

  final AppTab tab;
  final String label;
  final IconData icon;
}
