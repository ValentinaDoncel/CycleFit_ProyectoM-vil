import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class CyclePage extends StatelessWidget {
  const CyclePage({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Ciclo',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Visualiza y registra tu ciclo menstrual',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 0),
            child: Column(
              children: [
                SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fases del ciclo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 22,
                        runSpacing: 16,
                        children: controller.phaseLegend
                            .map((item) => _PhaseLegendTile(item: item))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: controller.goToPreviousMonth,
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                controller.visibleMonthLabel,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.goToNextMonth,
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Weekday('Dom'),
                            _Weekday('Lun'),
                            _Weekday('Mar'),
                            _Weekday('Mié'),
                            _Weekday('Jue'),
                            _Weekday('Vie'),
                            _Weekday('Sáb'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        itemCount: controller.calendarDays.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 6,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (context, index) {
                          return _CalendarDay(item: controller.calendarDays[index]);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _pickPeriodStart(context),
                    child: const Text(
                      'Registrar Inicio de Período',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => controller.selectTab(AppTab.symptoms),
                    child: const Text(
                      'Registrar síntomas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen del ciclo actual',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _SummaryRow(
                        label: 'Día del ciclo',
                        value: '${controller.currentCycleDay} de 28',
                      ),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        label: 'Fase actual',
                        value: controller.currentPhaseLabel,
                      ),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        label: 'Próximo período',
                        value: controller.nextPeriodLabel,
                      ),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        label: 'Período anterior',
                        value: controller.previousPeriodLabel,
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

  Future<void> _pickPeriodStart(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      await controller.registerPeriodStartDate(selectedDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de período registrado correctamente'),
          ),
        );
      }
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}

class _PhaseLegendTile extends StatelessWidget {
  const _PhaseLegendTile({required this.item});

  final PhaseLegendItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.days,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
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

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.item});

  final CalendarDayModel item;

  @override
  Widget build(BuildContext context) {
    if (item.isPlaceholder) {
      return const SizedBox.shrink();
    }

    final phaseColor = switch (item.phase) {
      CyclePhase.menstrual => AppColors.menstrual,
      CyclePhase.follicular => AppColors.follicular,
      CyclePhase.ovulatory => AppColors.ovulation,
      CyclePhase.luteal => AppColors.luteal,
    };
    final dotColor = switch (item.phase) {
      CyclePhase.menstrual => AppColors.menstrualDot,
      CyclePhase.follicular => AppColors.follicularDot,
      CyclePhase.ovulatory => AppColors.ovulationDot,
      CyclePhase.luteal => AppColors.lutealDot,
    };

    final hasOutline = item.isPeriodStart || item.isSelected;

    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.isSelected && !item.isPeriodStart ? Colors.transparent : phaseColor,
          border: Border.all(
            color: hasOutline ? AppColors.primary : Colors.transparent,
            width: hasOutline ? 2.4 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${item.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
            ),
            const SizedBox(height: 2),
            Container(
              width: item.isPeriodStart ? 7 : 6,
              height: item.isPeriodStart ? 7 : 6,
              decoration: BoxDecoration(
                color: item.isPeriodStart ? AppColors.primary : dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
