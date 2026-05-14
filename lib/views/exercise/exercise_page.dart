import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key, required this.controller});

  final AppController controller;

  static const Map<String, List<String>> _exerciseCatalog = {
    'Piernas': [
      'Sentadilla libre',
      'Sentadilla sumo',
      'Sentadilla bulgara',
      'Prensa de piernas inclinada',
      'Zancadas estaticas',
      'Zancadas caminando',
      'Extension de cuadriceps en maquina',
      'Curl femoral tumbado',
      'Curl femoral sentado',
      'Peso muerto rumano',
      'Peso muerto rigido',
      'Elevacion de talones',
    ],
    'Gluteos': [
      'Hip thrust con barra',
      'Puente de gluteo',
      'Patada de gluteo en polea',
      'Patada de gluteo en suelo',
      'Abducciones en maquina',
      'Abducciones con banda elastica',
      'Clamshells',
      'Step-ups en cajon',
      'Peso muerto sumo',
      'Frog pumps',
    ],
    'Espalda': [
      'Jalon al pecho agarre ancho',
      'Jalon al pecho agarre estrecho',
      'Remo con barra',
      'Remo con mancuerna a una mano',
      'Remo en polea baja',
      'Remo T',
      'Dominadas asistidas',
      'Pull-over con polea alta',
      'Pull-over con mancuerna',
      'Hiperextensiones lumbares',
      'Jalon tras nuca',
    ],
    'Torso': [
      'Press de banca con barra',
      'Press de pecho con mancuernas',
      'Flexiones de brazos',
      'Aperturas con mancuernas',
      'Press militar con barra',
      'Press de hombros con mancuernas',
      'Elevaciones laterales',
      'Elevaciones frontales',
      'Pajaros hombro posterior',
      'Face pull en polea',
      'Curl de biceps con mancuernas',
      'Curl de biceps con barra',
      'Extension de triceps en polea',
      'Press frances',
      'Fondos en banco',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final template = controller.consumePendingWorkoutTemplate();
    if (template != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _showAddWorkoutDialog(context, template: template);
      });
    }

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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registra tu actividad fisica',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  color: AppColors.primary,
                  onPressed: () => _showAddWorkoutDialog(context),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta semana',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: controller.workoutWeek
                        .map((item) => _WorkoutBar(item: item))
                        .toList(),
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
                Text(
                  'Historial',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                for (final workout in controller.recentWorkouts) ...[
                  _WorkoutHistoryItem(
                    workout: workout,
                    onView: () => _showWorkoutDetails(context, workout),
                    onShare: () => _showShareWorkoutDialog(context, workout),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddWorkoutDialog(
    BuildContext context, {
    WorkoutData? template,
  }) async {
    final titleController = TextEditingController(text: template?.title ?? '');
    final durationController = TextEditingController(
      text: template == null ? '' : '${template.durationMinutes}',
    );
    final caloriesController = TextEditingController(
      text: template == null ? '' : '${template.calories}',
    );
    var intensity = template?.intensity ?? 'Media';
    var selectedGroup = _exerciseCatalog.keys.first;
    final selected = <String, Set<String>>{
      for (final group in _exerciseCatalog.keys) group: <String>{},
    };
    if (template != null) {
      for (final exercise in template.exerciseNames) {
        for (final entry in _exerciseCatalog.entries) {
          if (entry.value.contains(exercise)) {
            selected[entry.key]!.add(exercise);
          }
        }
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final exercises = _exerciseCatalog[selectedGroup]!;
            return AlertDialog(
              title: Text(
                template == null
                    ? 'Nuevo entrenamiento'
                    : 'Guardar entrenamiento',
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: durationController,
                              decoration: const InputDecoration(
                                labelText: 'Minutos',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: caloriesController,
                              decoration: const InputDecoration(
                                labelText: 'Calorias',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Baja', label: Text('Baja')),
                          ButtonSegment(value: 'Media', label: Text('Media')),
                          ButtonSegment(value: 'Alta', label: Text('Alta')),
                        ],
                        selected: {intensity},
                        onSelectionChanged: (value) {
                          setState(() => intensity = value.first);
                        },
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _exerciseCatalog.keys.map((group) {
                          final active = selectedGroup == group;
                          return ChoiceChip(
                            label: Text(group),
                            selected: active,
                            onSelected: (_) =>
                                setState(() => selectedGroup = group),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      ...exercises.map((exercise) {
                        final checked = selected[selectedGroup]!.contains(
                          exercise,
                        );
                        return CheckboxListTile(
                          value: checked,
                          dense: true,
                          title: Text(exercise),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selected[selectedGroup]!.add(exercise);
                              } else {
                                selected[selectedGroup]!.remove(exercise);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
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
                            title: titleController.text.trim().isEmpty
                                ? 'Entrenamiento'
                                : titleController.text.trim(),
                            intensity: intensity,
                            durationMinutes:
                                int.tryParse(durationController.text) ?? 30,
                            calories:
                                int.tryParse(caloriesController.text) ?? 200,
                            exerciseGroups: {
                              for (final entry in selected.entries)
                                if (entry.value.isNotEmpty)
                                  entry.key: entry.value.toList()..sort(),
                            },
                          );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showShareWorkoutDialog(
    BuildContext context,
    WorkoutData workout,
  ) async {
    final textController = TextEditingController(
      text: 'Complete ${workout.title}.',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Compartir entrenamiento'),
        content: TextField(
          controller: textController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Texto de la publicacion',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.shareWorkoutToFeed(workout, textController.text);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Publicado en el feed')),
                );
              }
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWorkoutDetails(BuildContext context, WorkoutData workout) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(workout.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${workout.durationMinutes} min - ${workout.calories} kcal - ${workout.intensity}',
            ),
            const SizedBox(height: 12),
            for (final entry in workout.exerciseGroups.entries) ...[
              Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              ...entry.value.map((exercise) => Text('- $exercise')),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutBar extends StatelessWidget {
  const _WorkoutBar({required this.item});

  final WorkoutBarModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: item.isHidden ? 8 : 72 * item.heightFactor,
          decoration: BoxDecoration(
            color: item.isHidden ? Colors.transparent : AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(item.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WorkoutHistoryItem extends StatelessWidget {
  const _WorkoutHistoryItem({
    required this.workout,
    required this.onView,
    required this.onShare,
  });

  final WorkoutData workout;
  final VoidCallback onView;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${workout.durationMinutes} min - ${workout.exerciseNames.length} ejercicios',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onView,
            icon: const Icon(Icons.visibility_outlined),
          ),
          IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
    );
  }
}
