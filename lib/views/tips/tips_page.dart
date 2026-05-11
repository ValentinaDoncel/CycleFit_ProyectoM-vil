import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/views/tips/tips_recommendations_page.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    final heroes = controller.tipHeroes;
    final currentHero = heroes[controller.tipsCarouselIndex];
    final nextHero =
        heroes[(controller.tipsCarouselIndex + 1) % heroes.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(horizontal, 22, horizontal, 26),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips para ti',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Personalizados según tu ciclo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.isRefreshingTips
                      ? null
                      : () {
                          controller.refreshAiTips();
                        },
                  icon: controller.isRefreshingTips
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Día ${controller.currentCycleDay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TipsHeroCard(
                        hero: currentHero,
                        onTap: () => _openRecommendations(
                          context,
                          currentHero.id,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 108,
                      child: _TipsHeroCard(
                        hero: nextHero,
                        isPreview: true,
                        onTap: () => _openRecommendations(
                          context,
                          nextHero.id,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: -14,
                  top: 58,
                  child: _ArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: controller.previousTipHero,
                  ),
                ),
                Positioned(
                  right: -14,
                  top: 58,
                  child: _ArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: controller.nextTipHero,
                  ),
                ),
              ],
            ),
          ),
          if (controller.tipsError != null)
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
              child: SurfaceCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No pudimos actualizar los tips con IA en este momento. Te mostramos recomendaciones base mientras tanto.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.text,
                              height: 1.55,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tus insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
            child: Column(
              children: controller.tipInsights
                  .map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InsightCard(insight: insight),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _openRecommendations(BuildContext context, String heroId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TipsRecommendationsPage(
          controller: controller,
          initialFilter: _filterForHero(heroId),
        ),
      ),
    );
  }

  String _filterForHero(String heroId) {
    switch (heroId) {
      case 'nutrition':
        return 'Nutrición';
      case 'exercise':
        return 'Ejercicio';
      default:
        return 'Todos';
    }
  }
}

class _TipsHeroCard extends StatelessWidget {
  const _TipsHeroCard({
    required this.hero,
    required this.onTap,
    this.isPreview = false,
  });

  final TipHeroModel hero;
  final VoidCallback onTap;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 146,
        padding: EdgeInsets.fromLTRB(
          isPreview ? 14 : 18,
          14,
          isPreview ? 14 : 18,
          16,
        ),
        decoration: BoxDecoration(
          color: hero.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isPreview ? 38 : 42,
                  height: isPreview ? 38 : 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hero.icon,
                    color: Colors.white,
                    size: isPreview ? 20 : 24,
                  ),
                ),
                const Spacer(),
                if (!isPreview)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      hero.badge,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              isPreview ? hero.title : hero.subtitle,
              maxLines: isPreview ? 3 : 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: isPreview ? 15 : 16,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final TipInsightModel insight;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(insight.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                      ),
                ),
              ),
              Text(
                '${(insight.progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: insight.progress,
              minHeight: 6,
              backgroundColor: AppColors.progressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
