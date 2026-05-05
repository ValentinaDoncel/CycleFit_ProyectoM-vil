import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrenamientos',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registra tu actividad física',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _showAddWorkoutDialog(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Esta semana', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: controller.workoutWeek
                        .map(
                          (item) => _WorkoutBar(
                            label: item.label,
                            heightFactor: item.heightFactor,
                            isHidden: item.isHidden,
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: AppColors.border),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WorkoutSummary(
                      icon: Icons.fitness_center_rounded,
                      title: 'Entrenamientos',
                      value: '${controller.workoutsCount}',
                    ),
                    _WorkoutSummary(
                      icon: Icons.access_time_rounded,
                      title: 'Minutos',
                      value: '${controller.totalWorkoutMinutes}',
                    ),
                    _WorkoutSummary(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Calorías',
                      value: '${controller.totalWorkoutCalories}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendación para tu fase',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estás en fase ovulatoria. Tu fuerza y energía están en su pico máximo. Ideal para entrenamientos HIIT o de alta intensidad.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Historial',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                for (final item in controller.workoutHistory) ...[
                  _WorkoutHistoryItem(
                    title: item.title,
                    subtitle: item.subtitle,
                    trailing: item.trailing,
                    icon: item.icon,
                    highlightColor: item.highlightColor ?? AppColors.primarySoft,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddWorkoutDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final durationController = TextEditingController();
    final caloriesController = TextEditingController();
    var intensity = 'Media';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo entrenamiento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: 'Minutos'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: caloriesController,
                      decoration: const InputDecoration(labelText: 'Calorías'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: intensity,
                      items: const [
                        DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => intensity = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: controller.isSavingWorkout
                      ? null
                      : () async {
                          await controller.addWorkout(
                            title: titleController.text.isEmpty
                                ? 'Entrenamiento'
                                : titleController.text,
                            intensity: intensity,
                            durationMinutes:
                                int.tryParse(durationController.text) ?? 30,
                            calories: int.tryParse(caloriesController.text) ?? 200,
                          );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: Text(
                    controller.isSavingWorkout ? 'Guardando...' : 'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WorkoutBar extends StatelessWidget {
  const _WorkoutBar({
    required this.label,
    required this.heightFactor,
    required this.isHidden,
  });

  final String label;
  final double heightFactor;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: isHidden ? 8 : 72 * heightFactor,
          decoration: BoxDecoration(
            color: isHidden ? Colors.transparent : AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WorkoutSummary extends StatelessWidget {
  const _WorkoutSummary({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 6),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _WorkoutHistoryItem extends StatelessWidget {
  const _WorkoutHistoryItem({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.highlightColor,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: highlightColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: highlightColor),
            ),
            child: Text(
              trailing,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: highlightColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
