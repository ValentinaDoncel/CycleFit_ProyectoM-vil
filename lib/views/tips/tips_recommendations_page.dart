import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class TipsRecommendationsPage extends StatefulWidget {
  const TipsRecommendationsPage({
    super.key,
    required this.controller,
    this.initialFilter = 'Todos',
  });

  final AppController controller;
  final String initialFilter;

  @override
  State<TipsRecommendationsPage> createState() => _TipsRecommendationsPageState();
}

class _TipsRecommendationsPageState extends State<TipsRecommendationsPage> {
  late String _selectedFilter;
  static const _sectionOrder = [
    'Nutrición',
    'Descanso',
    'Actividad física',
    'Hidratación',
    'Bienestar mental',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final grouped = widget.controller.groupedTipsForFilter(_selectedFilter);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Recomendaciones',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                              ),
                          ),
                      ),
                      IconButton(
                        onPressed: widget.controller.isRefreshingTips
                            ? null
                            : () {
                                widget.controller.refreshAiTips();
                              },
                        icon: widget.controller.isRefreshingTips
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.controller.favoriteTipsCount} favoritos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _TipsFilters(
                    selectedFilter: _selectedFilter,
                    onSelected: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  if (widget.controller.isRefreshingTips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Actualizando recomendaciones con Gemini...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  if (grouped.isEmpty)
                    _EmptyFavoritesCard(
                      onShowAll: () {
                        setState(() {
                          _selectedFilter = 'Todos';
                        });
                      },
                    )
                  else
                    ..._sectionOrder
                        .where(grouped.containsKey)
                        .map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: _RecommendationSection(
                              title: section,
                              tips: grouped[section]!,
                              onFavoriteToggle: widget.controller.toggleTipFavorite,
                              onExpandToggle: widget.controller.toggleTipExpanded,
                            ),
                          ),
                        ),
                  const SizedBox(height: 6),
                  SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '¡Sigue registrando tu progreso!',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 15,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text(
                            'Cuanto más uses Cyclofit, más precisos serán estos consejos. La IA aprende de tus patrones únicos.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.65,
                                  color: AppColors.text,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MetricChip(label: '+50 registros'),
                            _MetricChip(label: '12 semanas activa'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TipsFilters extends StatelessWidget {
  const _TipsFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0E8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterChip(
              label: 'Todos',
              isSelected: selectedFilter == 'Todos',
              onTap: () => onSelected('Todos'),
            ),
          ),
          Expanded(
            child: _FilterChip(
              label: 'Nutrición',
              isSelected: selectedFilter == 'Nutrición',
              onTap: () => onSelected('Nutrición'),
            ),
          ),
          Expanded(
            child: _FilterChip(
              label: 'Ejercicio',
              isSelected: selectedFilter == 'Ejercicio',
              onTap: () => onSelected('Ejercicio'),
            ),
          ),
          _FavoriteFilterChip(
            isSelected: selectedFilter == 'Favoritos',
            onTap: () => onSelected('Favoritos'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _FavoriteFilterChip extends StatelessWidget {
  const _FavoriteFilterChip({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFD1A300),
          size: 19,
        ),
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({
    required this.title,
    required this.tips,
    required this.onFavoriteToggle,
    required this.onExpandToggle,
  });

  final String title;
  final List<TipRecommendationModel> tips;
  final ValueChanged<String> onFavoriteToggle;
  final ValueChanged<String> onExpandToggle;

  @override
  Widget build(BuildContext context) {
    final reference = tips.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: reference.sectionColor,
                shape: BoxShape.circle,
              ),
              child: Icon(reference.icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 17,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE1E3CF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${tips.length} tips',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RecommendationCard(
              tip: tip,
              onFavoriteToggle: () => onFavoriteToggle(tip.id),
              onExpandToggle: () => onExpandToggle(tip.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.tip,
    required this.onFavoriteToggle,
    required this.onExpandToggle,
  });

  final TipRecommendationModel tip;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onExpandToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: tip.tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tip.sectionColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  tip.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                        color: tip.sectionColor,
                      ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: onFavoriteToggle,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    tip.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: tip.sectionColor,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip.description,
            maxLines: tip.isExpanded ? null : 2,
            overflow: tip.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: tip.sectionColor,
                  height: 1.65,
                ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onExpandToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tip.isExpanded ? 'Ver menos' : 'Ver más',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tip.sectionColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 3),
                Icon(
                  tip.isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: tip.sectionColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EmptyFavoritesCard extends StatelessWidget {
  const _EmptyFavoritesCard({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aún no tienes tips favoritos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            'Marca la estrella de cualquier recomendación para guardarla aquí y revisarla más tarde.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onShowAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Ver todas las recomendaciones'),
          ),
        ],
      ),
    );
  }
}
