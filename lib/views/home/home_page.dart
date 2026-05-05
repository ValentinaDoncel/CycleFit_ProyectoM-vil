import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/widgets/section_title.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, María',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.currentDateLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(34),
                onTap: () => controller.selectTab(AppTab.profile),
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(controller.profileAvatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fase actual',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.brightness_3_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ovulatoria',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.secondary, width: 2),
                        color: const Color(0xFFF8EEFF),
                      ),
                      child: Text(
                        'Día 14',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFFB04FFB),
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.progressTrack,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 42),
                const Row(
                  children: [
                    Expanded(
                      child: _MetricBlock(
                        title: 'Duración ciclo',
                        value: '28 días',
                      ),
                    ),
                    Expanded(
                      child: _MetricBlock(
                        title: 'Próximo período',
                        value: 'En 14 días',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const SectionTitle('Acceso rápido'),
          const SizedBox(height: 22),
          Row(
            children: [
              for (var i = 0; i < controller.quickActions.length; i++) ...[
                Expanded(
                  child: _QuickAccessCard(
                    action: controller.quickActions[i],
                    onTap: () =>
                        controller.selectTab(controller.quickActions[i].targetTab),
                  ),
                ),
                if (i == 0) const SizedBox(width: 22),
              ],
            ],
          ),
          const SizedBox(height: 22),
          SurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendación del día',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Durante la fase ovulatoria, tu energía está en su punto máximo. Es un excelente momento para entrenamientos de alta intensidad.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ver más consejos →',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
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

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.action,
    required this.onTap,
  });

  final QuickActionModel action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 18),
            Text(action.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              action.subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
