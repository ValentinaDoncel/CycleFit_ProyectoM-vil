import 'dart:convert';

import 'package:cycle_fit/models/app_models.dart';
import 'package:firebase_ai/firebase_ai.dart';

enum FirebaseAiProvider {
  googleAI,
  vertexAI,
}

class GeminiTipsService {
  const GeminiTipsService({
    this.provider = FirebaseAiProvider.googleAI,
    this.modelName = 'gemini-2.5-flash',
    this.vertexLocation = 'us-central1',
  });

  final FirebaseAiProvider provider;
  final String modelName;
  final String vertexLocation;

  Future<AiTipsPayload> generateRecommendations({
    required UserProfileData profile,
    required CycleData cycle,
    required int currentCycleDay,
    required String currentPhase,
    required double currentEnergyLevel,
    required List<String> currentMoods,
    required List<String> currentSymptoms,
    required List<SymptomRecordData> recentSymptoms,
    required List<WorkoutData> recentWorkouts,
  }) async {
    final model = _backend.generativeModel(model: modelName);
    final prompt = _buildPrompt(
      profile: profile,
      cycle: cycle,
      currentCycleDay: currentCycleDay,
      currentPhase: currentPhase,
      currentEnergyLevel: currentEnergyLevel,
      currentMoods: currentMoods,
      currentSymptoms: currentSymptoms,
      recentSymptoms: recentSymptoms,
      recentWorkouts: recentWorkouts,
    );

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('Gemini no devolvió contenido.');
    }

    final decoded = jsonDecode(_extractJson(text));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('La respuesta de Gemini no tiene el formato esperado.');
    }

    final payload = AiTipsPayload.fromMap(decoded);
    if (payload.recommendations.isEmpty) {
      throw const FormatException('Gemini no devolvió recomendaciones utilizables.');
    }

    return payload;
  }

  FirebaseAI get _backend {
    switch (provider) {
      case FirebaseAiProvider.vertexAI:
        return FirebaseAI.vertexAI(location: vertexLocation);
      case FirebaseAiProvider.googleAI:
        return FirebaseAI.googleAI();
    }
  }

  String _buildPrompt({
    required UserProfileData profile,
    required CycleData cycle,
    required int currentCycleDay,
    required String currentPhase,
    required double currentEnergyLevel,
    required List<String> currentMoods,
    required List<String> currentSymptoms,
    required List<SymptomRecordData> recentSymptoms,
    required List<WorkoutData> recentWorkouts,
  }) {
    final symptomSummary = recentSymptoms.take(5).map((record) {
      return {
        'date': record.documentId,
        'energyLevel': record.energyLevel.round(),
        'moods': record.moodKeys,
        'symptoms': record.symptomKeys,
      };
    }).toList();

    final workoutSummary = recentWorkouts.take(6).map((workout) {
      return {
        'date':
            '${workout.date.year}-${workout.date.month.toString().padLeft(2, '0')}-${workout.date.day.toString().padLeft(2, '0')}',
        'title': workout.title,
        'intensity': workout.intensity,
        'durationMinutes': workout.durationMinutes,
        'calories': workout.calories,
      };
    }).toList();

    final context = {
      'profile': {
        'name': profile.name,
        'age': profile.age,
        'goal': profile.goal,
        'weightKg': profile.weightKg,
      },
      'cycle': {
        'cycleLength': cycle.cycleLength,
        'currentCycleDay': currentCycleDay,
        'currentPhase': currentPhase,
        'currentEnergyLevel': currentEnergyLevel.round(),
      },
      'today': {
        'moods': currentMoods,
        'symptoms': currentSymptoms,
      },
      'recentSymptoms': symptomSummary,
      'recentWorkouts': workoutSummary,
    };

    return '''
Eres una especialista en bienestar femenino, entrenamiento, descanso y nutrición.
Genera recomendaciones útiles, específicas, accionables, breves y seguras para una app llamada CycleFit.
Debes personalizar según el ciclo menstrual, síntomas, estado de ánimo y entrenamientos recientes.
No uses markdown. No agregues introducciones. Devuelve SOLO JSON válido UTF-8.

Reglas:
- Escribe todo en español.
- Usa exactamente estas secciones para recomendaciones: "Nutrición", "Descanso", "Actividad física", "Hidratación", "Bienestar mental".
- Devuelve entre 2 y 3 recomendaciones por sección.
- Cada recomendación debe ser breve, concreta y pensada para mostrarse en UI móvil.
- Evita lenguaje médico concluyente o diagnósticos.
- Los insights deben incluir un progress entre 0 y 100.
- Los heroes deben usar ids de esta lista: hydration, nutrition, exercise.
- Para heroes, category debe ser una de: "Hidratación", "Nutrición", "Ejercicio".

Estructura exacta:
{
  "heroes": [
    {"id": "hydration", "category": "Hidratación", "message": "..."},
    {"id": "nutrition", "category": "Nutrición", "message": "..."},
    {"id": "exercise", "category": "Ejercicio", "message": "..."}
  ],
  "insights": [
    {"title": "...", "description": "...", "progress": 0}
  ],
  "recommendations": [
    {"section": "Nutrición", "title": "...", "description": "..."}
  ]
}

Contexto de la usuaria:
${jsonEncode(context)}
''';
  }

  String _extractJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('```')) {
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        return trimmed.substring(start, end + 1);
      }
    }
    return trimmed;
  }
}
