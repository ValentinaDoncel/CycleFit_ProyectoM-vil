import 'dart:async';

import 'package:cycle_fit/core/services/firebase/cycle_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/firebase_auth_service.dart';
import 'package:cycle_fit/core/services/firebase/profile_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/symptoms_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/workouts_firestore_service.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  AppController({
    ProfileFirestoreService? profileService,
    CycleFirestoreService? cycleService,
    SymptomsFirestoreService? symptomsService,
    WorkoutsFirestoreService? workoutsService,
  })  : _profileService = profileService ?? const ProfileFirestoreService(),
        _cycleService = cycleService ?? const CycleFirestoreService(),
        _symptomsService = symptomsService ?? const SymptomsFirestoreService(),
        _workoutsService = workoutsService ?? const WorkoutsFirestoreService();

  final ProfileFirestoreService _profileService;
  final CycleFirestoreService _cycleService;
  final SymptomsFirestoreService _symptomsService;
  final WorkoutsFirestoreService _workoutsService;

  AppTab _selectedTab = AppTab.home;
  final DateTime _today = _currentDateOnly();
  late DateTime _visibleMonth = DateTime(_today.year, _today.month, 1);
  UserProfileData _profile = UserProfileData.initial();
  CycleData _cycleData = CycleData.initial();
  List<WorkoutData> _workouts = const [];
  List<SymptomRecordData> _recentSymptoms = const [];
  double _energyLevel = 50;
  final Set<String> _selectedMoodKeys = {};
  final Set<String> _selectedSymptomKeys = {};
  int _tipsCarouselIndex = 0;
  String _tipsFilter = 'Todos';
  final Set<String> _favoriteTipIds = {};
  final Set<String> _expandedTipIds = {};
  bool _isInitializing = true;
  bool _isSavingSymptoms = false;
  bool _isSavingProfile = false;
  bool _isSavingWorkout = false;
  String? _userId;
  String? _lastError;

  static const List<Map<String, dynamic>> _moodCatalog = [
    {'key': 'calmada', 'label': 'Calmada', 'icon': Icons.favorite_border_rounded},
    {'key': 'feliz', 'label': 'Feliz', 'icon': Icons.sentiment_satisfied_alt_outlined},
    {'key': 'energica', 'label': 'Enérgica', 'icon': Icons.bolt_rounded},
    {'key': 'coqueta', 'label': 'Coqueta', 'icon': Icons.favorite_outline_rounded},
    {'key': 'humor', 'label': 'Cambios de\nhumor', 'icon': Icons.mood_bad_outlined},
    {'key': 'irritable', 'label': 'Irritable', 'icon': Icons.sentiment_dissatisfied_outlined},
    {'key': 'triste', 'label': 'Triste', 'icon': Icons.sentiment_neutral_outlined},
    {'key': 'ansiosa', 'label': 'Ansiosa', 'icon': Icons.warning_amber_rounded},
    {'key': 'deprimida', 'label': 'Deprimida', 'icon': Icons.self_improvement_outlined},
    {'key': 'culpa', 'label': 'Sentimientos\nde culpa', 'icon': Icons.psychology_alt_outlined},
    {'key': 'obsesivos', 'label': 'Pensamientos\nobsesivos', 'icon': Icons.psychology_outlined},
    {'key': 'baja_energia', 'label': 'Baja energía', 'icon': Icons.battery_1_bar_rounded},
    {'key': 'apatica', 'label': 'Apática', 'icon': Icons.accessibility_new_outlined},
    {'key': 'confundida', 'label': 'Confundida', 'icon': Icons.change_circle_outlined},
    {'key': 'autocritica', 'label': 'Muy\nautocrítica', 'icon': Icons.error_outline_rounded},
  ];

  static const List<Map<String, dynamic>> _symptomCatalog = [
    {'key': 'todo_bien', 'label': 'Todo está bien', 'icon': Icons.check_circle_outline_rounded},
    {'key': 'colicos', 'label': 'Cólicos', 'icon': Icons.show_chart_rounded},
    {'key': 'senos_sensibles', 'label': 'Senos\nsensibles', 'icon': Icons.favorite_border_rounded},
    {'key': 'dolor_cabeza', 'label': 'Dolor de\ncabeza', 'icon': Icons.psychology_alt_outlined},
    {'key': 'acne', 'label': 'Acné', 'icon': Icons.face_retouching_natural_outlined},
    {'key': 'dolor_espalda', 'label': 'Dolor de\nespalda', 'icon': Icons.show_chart_outlined},
    {'key': 'fatiga', 'label': 'Fatiga', 'icon': Icons.battery_alert_outlined},
    {'key': 'antojos', 'label': 'Antojos', 'icon': Icons.apple_rounded},
    {'key': 'insomnio', 'label': 'Insomnio', 'icon': Icons.brightness_2_outlined},
    {'key': 'dolor_abdominal', 'label': 'Dolor\nabdominal', 'icon': Icons.sick_outlined},
    {'key': 'picazon', 'label': 'Picazón\nvaginal', 'icon': Icons.warning_amber_rounded},
    {'key': 'sequedad', 'label': 'Sequedad\nvaginal', 'icon': Icons.air_rounded},
    {'key': 'sofocos', 'label': 'Sofocos', 'icon': Icons.local_fire_department_outlined},
    {'key': 'sudores', 'label': 'Sudores\nnocturnos', 'icon': Icons.grain_outlined},
  ];

  AppTab get selectedTab => _selectedTab;
  bool get isInitializing => _isInitializing;
  bool get isSavingSymptoms => _isSavingSymptoms;
  bool get isSavingProfile => _isSavingProfile;
  bool get isSavingWorkout => _isSavingWorkout;
  String? get lastError => _lastError;
  double get energyLevel => _energyLevel;
  int get tipsCarouselIndex => _tipsCarouselIndex;
  String get tipsFilter => _tipsFilter;
  int get favoriteTipsCount => _favoriteTipIds.length;

  Future<void> initialize() async {
    if (!_isInitializing) return;

    try {
      final user = await FirebaseAuthService.ensureSignedIn();
      _userId = user.uid;

      final results = await Future.wait([
        _profileService.getProfile(user.uid),
        _cycleService.getCycle(user.uid),
        _symptomsService.getRecordForDay(user.uid, _today),
        _symptomsService.getRecentRecords(user.uid, limit: 8),
        _workoutsService.getWorkouts(user.uid),
      ]);

      _profile = results[0] as UserProfileData;
      _cycleData = results[1] as CycleData;
      _visibleMonth = DateTime(_today.year, _today.month, 1);
      final todayRecord = results[2] as SymptomRecordData?;
      _recentSymptoms = results[3] as List<SymptomRecordData>;
      _workouts = results[4] as List<WorkoutData>;

      if (todayRecord != null) {
        _energyLevel = todayRecord.energyLevel;
        _selectedMoodKeys
          ..clear()
          ..addAll(todayRecord.moodKeys);
        _selectedSymptomKeys
          ..clear()
          ..addAll(todayRecord.symptomKeys);
      } else {
        _energyLevel = 50;
        _selectedMoodKeys
          ..clear()
          ..addAll({'calmada', 'feliz'});
        _selectedSymptomKeys
          ..clear()
          ..addAll({'todo_bien'});
      }
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  String get currentDateLabel =>
      '${_weekdayName(_today.weekday)}, ${_today.day} de ${_monthName(_today.month)}';

  String get currentCycleDayLabel =>
      'Día $currentCycleDay del ciclo • Fase $currentPhaseLabel';

  String get visibleMonthLabel =>
      '${_monthName(_visibleMonth.month)} de ${_visibleMonth.year}';

  int get currentCycleDay => _cycleDayForDate(_today);
  String get currentPhaseLabel => _phaseLabel(_phaseForDate(_today));
  String get nextPeriodLabel => _formatDate(
        _cycleData.periodStartDate.add(Duration(days: _cycleData.cycleLength)),
      );
  String get previousPeriodLabel => _formatDate(_cycleData.periodStartDate);
  String get profileName => _profile.name;
  String get profileEmail => _profile.email;
  String get profileAvatarUrl => _profile.avatarUrl;
  int get workoutsCount => _workouts.length;
  int get totalWorkoutMinutes =>
      _workouts.fold(0, (sum, item) => sum + item.durationMinutes);
  int get totalWorkoutCalories =>
      _workouts.fold(0, (sum, item) => sum + item.calories);

  void selectTab(AppTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void nextTipHero() {
    _tipsCarouselIndex = (_tipsCarouselIndex + 1) % tipHeroes.length;
    notifyListeners();
  }

  void previousTipHero() {
    _tipsCarouselIndex =
        (_tipsCarouselIndex - 1 + tipHeroes.length) % tipHeroes.length;
    notifyListeners();
  }

  void selectTipsFilter(String filter) {
    _tipsFilter = filter;
    notifyListeners();
  }

  void toggleTipFavorite(String tipId) {
    if (_favoriteTipIds.contains(tipId)) {
      _favoriteTipIds.remove(tipId);
    } else {
      _favoriteTipIds.add(tipId);
    }
    notifyListeners();
  }

  void toggleTipExpanded(String tipId) {
    if (_expandedTipIds.contains(tipId)) {
      _expandedTipIds.remove(tipId);
    } else {
      _expandedTipIds.add(tipId);
    }
    notifyListeners();
  }

  void updateEnergyLevel(double value) {
    _energyLevel = value.clamp(0, 100);
    notifyListeners();
  }

  void toggleMood(String key) {
    if (_selectedMoodKeys.contains(key)) {
      _selectedMoodKeys.remove(key);
    } else {
      _selectedMoodKeys.add(key);
    }
    notifyListeners();
  }

  void toggleSymptom(String key) {
    if (_selectedSymptomKeys.contains(key)) {
      _selectedSymptomKeys.remove(key);
    } else {
      _selectedSymptomKeys.add(key);
    }
    notifyListeners();
  }

  Future<void> saveSymptomsRecord() async {
    if (_userId == null) return;
    _isSavingSymptoms = true;
    notifyListeners();

    try {
      final record = SymptomRecordData(
        date: DateTime(_today.year, _today.month, _today.day),
        energyLevel: _energyLevel,
        moodKeys: _selectedMoodKeys.toList()..sort(),
        symptomKeys: _selectedSymptomKeys.toList()..sort(),
      );
      await _symptomsService.saveRecord(_userId!, record);
      _recentSymptoms = await _symptomsService.getRecentRecords(_userId!, limit: 8);
    } finally {
      _isSavingSymptoms = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfileData profile) async {
    if (_userId == null) return;
    _isSavingProfile = true;
    notifyListeners();

    try {
      await _profileService.saveProfile(_userId!, profile);
      _profile = profile;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout({
    required String title,
    required String intensity,
    required int durationMinutes,
    required int calories,
    DateTime? date,
  }) async {
    if (_userId == null) return;
    _isSavingWorkout = true;
    notifyListeners();

    try {
      await _workoutsService.addWorkout(
        _userId!,
        WorkoutData(
          id: '',
          title: title,
          intensity: intensity,
          durationMinutes: durationMinutes,
          calories: calories,
          date: date ?? _today,
        ),
      );
      _workouts = await _workoutsService.getWorkouts(_userId!);
    } finally {
      _isSavingWorkout = false;
      notifyListeners();
    }
  }

  void goToPreviousMonth() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    notifyListeners();
  }

  Future<void> registerPeriodStartDate(DateTime date) async {
    _cycleData = CycleData(
      periodStartDate: DateTime(date.year, date.month, date.day),
      cycleLength: _cycleData.cycleLength,
    );
    _visibleMonth = DateTime(date.year, date.month, 1);
    notifyListeners();

    if (_userId != null) {
      await _cycleService.saveCycle(_userId!, _cycleData);
    }
  }

  List<QuickActionModel> get quickActions => const [
        QuickActionModel(
          title: 'Síntomas',
          subtitle: 'Registrar hoy',
          icon: Icons.favorite_border_rounded,
          targetTab: AppTab.symptoms,
        ),
        QuickActionModel(
          title: 'Entrenar',
          subtitle: 'Nuevo registro',
          icon: Icons.fitness_center_rounded,
          targetTab: AppTab.exercise,
        ),
      ];

  List<PhaseLegendItem> get phaseLegend => const [
        PhaseLegendItem(
          title: 'Menstrual',
          days: 'Días 1-5',
          icon: Icons.water_drop_outlined,
          color: Color(0xFFFF3E45),
        ),
        PhaseLegendItem(
          title: 'Folicular',
          days: 'Días 6-11',
          icon: Icons.wb_sunny_outlined,
          color: Color(0xFF09C754),
        ),
        PhaseLegendItem(
          title: 'Ovulatoria',
          days: 'Días 12-16',
          icon: Icons.brightness_3_outlined,
          color: Color(0xFFA645F8),
        ),
        PhaseLegendItem(
          title: 'Lútea',
          days: 'Días 17-28',
          icon: Icons.show_chart_rounded,
          color: Color(0xFFF4B200),
        ),
      ];

  List<CalendarDayModel> get calendarDays {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final totalDays =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingSlots = firstDay.weekday % 7;
    final items = <CalendarDayModel>[];

    for (var i = 0; i < leadingSlots; i++) {
      items.add(
        const CalendarDayModel(
          day: 0,
          phase: CyclePhase.menstrual,
          isPlaceholder: true,
        ),
      );
    }

    for (var day = 1; day <= totalDays; day++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      items.add(
        CalendarDayModel(
          day: day,
          phase: _phaseForDate(date),
          isSelected: _isSameDate(date, _today),
          isPeriodStart: _isSameDate(date, _cycleData.periodStartDate),
        ),
      );
    }

    return items;
  }

  List<SelectableOptionModel> get moodOptions => _moodCatalog
      .map(
        (item) => SelectableOptionModel(
          keyName: item['key'] as String,
          label: item['label'] as String,
          icon: item['icon'] as IconData,
          isSelected: _selectedMoodKeys.contains(item['key']),
        ),
      )
      .toList();

  List<SelectableOptionModel> get symptomOptions => _symptomCatalog
      .map(
        (item) => SelectableOptionModel(
          keyName: item['key'] as String,
          label: item['label'] as String,
          icon: item['icon'] as IconData,
          isSelected: _selectedSymptomKeys.contains(item['key']),
        ),
      )
      .toList();

  List<HistoryEntryModel> get symptomsHistory => _recentSymptoms.map((record) {
        return HistoryEntryModel(
          title: '${record.date.day} ${_monthShort(record.date.month)}',
          subtitle:
              'Energía: ${record.energyLevel.round()}% • Síntomas: ${record.symptomKeys.length}',
          trailing: '',
          icon: Icons.favorite_border_rounded,
          highlightColor: AppColors.primary,
        );
      }).toList();

  List<WorkoutBarModel> get workoutWeek {
    final startOfWeek = _today.subtract(Duration(days: _today.weekday - 1));
    final totals = List<int>.filled(7, 0);

    for (final workout in _workouts) {
      final workoutDay = DateTime(workout.date.year, workout.date.month, workout.date.day);
      final diff = workoutDay.difference(
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      ).inDays;
      if (diff >= 0 && diff < 7) {
        totals[diff] += workout.durationMinutes;
      }
    }

    final maxMinutes = totals.fold<int>(1, (current, next) => next > current ? next : current);
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return List.generate(7, (index) {
      final minutes = totals[index];
      return WorkoutBarModel(
        label: labels[index],
        heightFactor: minutes == 0 ? 0 : minutes / maxMinutes,
        isHidden: minutes == 0,
      );
    });
  }

  List<HistoryEntryModel> get workoutHistory => _workouts.take(6).map((workout) {
        return HistoryEntryModel(
          title: workout.title,
          subtitle:
              '${workout.date.day} ${_monthShort(workout.date.month)} • ${workout.durationMinutes} min • ${workout.calories} kcal',
          trailing: workout.intensity,
          icon: Icons.fitness_center_rounded,
          highlightColor: _intensityColor(workout.intensity),
        );
      }).toList();

  List<PostModel> get posts => const [
        PostModel(
          author: 'María García',
          timeAgo: 'Hace 2 horas',
          content:
              '¡Completé mi entrenamiento de cardio hoy! Me siento increíble durante mi fase ovulatoria 💪✨',
          avatar: 'MG',
          likes: 24,
          comments: 1,
          imageUrl:
              'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=1200&q=80',
        ),
        PostModel(
          author: 'Laura Martínez',
          timeAgo: 'Hace 5 horas',
          content:
              'Día de yoga suave. Escuchando a mi cuerpo durante la fase lútea 🙏',
          avatar: 'LM',
          likes: 18,
          comments: 0,
        ),
      ];

  List<TipHeroModel> get tipHeroes => const [
        TipHeroModel(
          id: 'hydration',
          title: 'Hidratación',
          subtitle: 'Has alcanzado tu meta de agua 5 días seguidos. ¡Sigue así!',
          badge: 'Hidratación',
          icon: Icons.opacity_rounded,
          backgroundColor: Color(0xFF15A9E8),
        ),
        TipHeroModel(
          id: 'nutrition',
          title: 'Nutrición',
          subtitle: 'Incluye alimentos verdes para prepararte mejor en esta fase.',
          badge: 'Nutrición',
          icon: Icons.eco_rounded,
          backgroundColor: Color(0xFF10C55A),
        ),
        TipHeroModel(
          id: 'exercise',
          title: 'Entrenamiento',
          subtitle: 'Tu energía está alta: aprovecha sesiones cortas e intensas.',
          badge: 'Ejercicio',
          icon: Icons.bolt_rounded,
          backgroundColor: Color(0xFFFF6E63),
        ),
      ];

  List<TipInsightModel> get tipInsights => const [
        TipInsightModel(
          title: 'Tu patrón de energía',
          description:
              'Hemos notado que tu energía es más alta entre las fases folicular y ovulatoria. Planifica tus actividades importantes en estos días.',
          progress: 0.85,
          icon: Icons.bolt_rounded,
        ),
        TipInsightModel(
          title: 'Consistencia en entrenamientos',
          description:
              'Has mantenido 4-5 entrenamientos semanales. ¡Excelente! Esto contribuye a regular tu ciclo hormonal.',
          progress: 0.92,
          icon: Icons.trending_up_rounded,
        ),
        TipInsightModel(
          title: 'Mejora en síntomas',
          description:
              'Tus registros muestran una reducción del 30% en dolor durante los últimos 3 ciclos. Sigue así.',
          progress: 0.70,
          icon: Icons.favorite_border_rounded,
        ),
      ];

  List<TipRecommendationModel> get _tipsCatalog => const [
        TipRecommendationModel(
          id: 'nutri_proteinas',
          section: 'Nutrición',
          title: 'Aumenta proteínas',
          description:
              'Durante la fase ovulatoria, tu metabolismo está más activo. Consume proteínas de calidad para mantener energía estable y favorecer la recuperación.',
          icon: Icons.apple_rounded,
          tint: Color(0xFFD9F9E4),
          sectionColor: Color(0xFF10C55A),
        ),
        TipRecommendationModel(
          id: 'nutri_calcio',
          section: 'Nutrición',
          title: 'Alimentos ricos en calcio',
          description:
              'El calcio ayuda a reducir los síntomas premenstruales. Incluye lácteos, almendras y vegetales de hoja verde.',
          icon: Icons.apple_rounded,
          tint: Color(0xFFD9F9E4),
          sectionColor: Color(0xFF10C55A),
        ),
        TipRecommendationModel(
          id: 'nutri_omega',
          section: 'Nutrición',
          title: 'Omega-3 para el equilibrio',
          description:
              'Los ácidos grasos Omega-3 ayudan a reducir la inflamación y los calambres menstruales.',
          icon: Icons.apple_rounded,
          tint: Color(0xFFD9F9E4),
          sectionColor: Color(0xFF10C55A),
        ),
        TipRecommendationModel(
          id: 'rest_horario',
          section: 'Descanso',
          title: 'Mantén un horario regular',
          description:
              'Dormir y despertar a las mismas horas ayuda a regular tus hormonas y mejora la calidad del sueño.',
          icon: Icons.nightlight_round,
          tint: Color(0xFFF0E2FF),
          sectionColor: Color(0xFFA445F7),
        ),
        TipRecommendationModel(
          id: 'rest_cafeina',
          section: 'Descanso',
          title: 'Evita cafeína tarde',
          description:
              'Limita el consumo de cafeína después de las 4 PM para mejorar la calidad de tu descanso nocturno.',
          icon: Icons.nightlight_round,
          tint: Color(0xFFF0E2FF),
          sectionColor: Color(0xFFA445F7),
        ),
        TipRecommendationModel(
          id: 'fit_energia',
          section: 'Actividad física',
          title: 'Aprovecha tu energía',
          description:
              'Estás en tu punto máximo de energía. Es el momento ideal para entrenamientos de alta intensidad o probando nuevas rutinas.',
          icon: Icons.fitness_center_rounded,
          tint: Color(0xFFFFE0E0),
          sectionColor: Color(0xFFFF564E),
        ),
        TipRecommendationModel(
          id: 'fit_fuerza',
          section: 'Actividad física',
          title: 'Fuerza y resistencia',
          description:
              'Tu fuerza muscular está aumentada. Enfócate en ejercicios de fuerza y entrenamiento de resistencia.',
          icon: Icons.fitness_center_rounded,
          tint: Color(0xFFFFE0E0),
          sectionColor: Color(0xFFFF564E),
        ),
        TipRecommendationModel(
          id: 'fit_cuerpo',
          section: 'Actividad física',
          title: 'Escucha tu cuerpo',
          description:
              'Ajusta la intensidad según tu fase. En fase lútea, opta por yoga, pilates o caminatas.',
          icon: Icons.fitness_center_rounded,
          tint: Color(0xFFFFE0E0),
          sectionColor: Color(0xFFFF564E),
        ),
        TipRecommendationModel(
          id: 'hidra_agua',
          section: 'Hidratación',
          title: 'Bebe 2-3 litros diarios',
          description:
              'La hidratación adecuada ayuda a reducir la retención de líquidos y mejora tu energía general.',
          icon: Icons.opacity_rounded,
          tint: Color(0xFFDCEAFF),
          sectionColor: Color(0xFF377EF7),
        ),
        TipRecommendationModel(
          id: 'hidra_infusiones',
          section: 'Hidratación',
          title: 'Infusiones naturales',
          description:
              'Las infusiones de jengibre o manzanilla pueden ayudar con los calambres y la inflamación.',
          icon: Icons.opacity_rounded,
          tint: Color(0xFFDCEAFF),
          sectionColor: Color(0xFF377EF7),
        ),
        TipRecommendationModel(
          id: 'hidra_electrolitos',
          section: 'Hidratación',
          title: 'Electrolitos naturales',
          description:
              'Agua de coco o bebidas con electrolitos naturales para recuperación post-entrenamiento.',
          icon: Icons.opacity_rounded,
          tint: Color(0xFFDCEAFF),
          sectionColor: Color(0xFF377EF7),
        ),
        TipRecommendationModel(
          id: 'mind_meditacion',
          section: 'Bienestar mental',
          title: 'Meditación diaria',
          description:
              '10-15 minutos de meditación ayudan a reducir el estrés y equilibrar tus hormonas.',
          icon: Icons.spa_outlined,
          tint: Color(0xFFFFE0F2),
          sectionColor: Color(0xFFFF3D96),
        ),
        TipRecommendationModel(
          id: 'mind_journal',
          section: 'Bienestar mental',
          title: 'Journaling emocional',
          description:
              'Registra tus emociones diarias para identificar patrones y manejar mejor los cambios de humor.',
          icon: Icons.spa_outlined,
          tint: Color(0xFFFFE0F2),
          sectionColor: Color(0xFFFF3D96),
        ),
      ];

  List<TipRecommendationModel> get filteredTips {
    return tipsForFilter(_tipsFilter);
  }

  Map<String, List<TipRecommendationModel>> get groupedTips {
    return groupedTipsForFilter(_tipsFilter);
  }

  List<TipRecommendationModel> tipsForFilter(String filter) {
    final tips = _tipsCatalog.map((tip) {
      return tip.copyWith(
        isFavorite: _favoriteTipIds.contains(tip.id),
        isExpanded: _expandedTipIds.contains(tip.id),
      );
    }).toList();

    switch (filter) {
      case 'Nutrición':
        return tips.where((tip) => tip.section == 'Nutrición').toList();
      case 'Ejercicio':
        return tips.where((tip) => tip.section == 'Actividad física').toList();
      case 'Favoritos':
        return tips.where((tip) => tip.isFavorite).toList();
      default:
        return tips;
    }
  }

  Map<String, List<TipRecommendationModel>> groupedTipsForFilter(String filter) {
    final map = <String, List<TipRecommendationModel>>{};
    for (final tip in tipsForFilter(filter)) {
      map.putIfAbsent(tip.section, () => []).add(tip);
    }
    return map;
  }

  List<ProfileInfoItem> get profileInfo => [
        ProfileInfoItem(
          label: 'Nombre completo',
          value: _profile.name,
          icon: Icons.person_outline_rounded,
        ),
        ProfileInfoItem(
          label: 'Email',
          value: _profile.email,
          icon: Icons.email_outlined,
        ),
        ProfileInfoItem(
          label: 'Edad',
          value: '${_profile.age} años',
          icon: Icons.calendar_today_outlined,
        ),
        ProfileInfoItem(
          label: 'Peso',
          value: '${_profile.weightKg.toStringAsFixed(0)} kg',
          icon: Icons.monitor_weight_outlined,
        ),
        ProfileInfoItem(
          label: 'Objetivo principal',
          value: _profile.goal,
          icon: Icons.gps_fixed_rounded,
        ),
      ];

  List<ProfileStatItem> get profileStats => [
        const ProfileStatItem(value: '1', label: 'Ciclos\nregistrados'),
        ProfileStatItem(value: '$workoutsCount', label: 'Entrenamientos'),
        ProfileStatItem(
          value: '${_recentSymptoms.length}',
          label: 'Días activa',
        ),
      ];

  List<ProfileMenuItem> get profileMenu => const [
        ProfileMenuItem(
          title: 'Notificaciones',
          subtitle: 'Recordatorios y alertas',
          icon: Icons.notifications_none_rounded,
        ),
        ProfileMenuItem(
          title: 'Privacidad y seguridad',
          subtitle: 'Gestiona tus datos',
          icon: Icons.lock_outline_rounded,
        ),
        ProfileMenuItem(
          title: 'Ayuda y soporte',
          subtitle: 'Preguntas frecuentes',
          icon: Icons.help_outline_rounded,
        ),
        ProfileMenuItem(
          title: 'Configuración',
          subtitle: 'Preferencias de la app',
          icon: Icons.settings_outlined,
        ),
      ];

  int _cycleDayForDate(DateTime date) {
    final difference = date.difference(_cycleData.periodStartDate).inDays;
    final normalized = difference % _cycleData.cycleLength;
    return normalized + 1;
  }

  CyclePhase _phaseForDate(DateTime date) {
    final cycleDay = _cycleDayForDate(date);
    if (cycleDay <= 5) return CyclePhase.menstrual;
    if (cycleDay <= 11) return CyclePhase.follicular;
    if (cycleDay <= 16) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  String _phaseLabel(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Folicular';
      case CyclePhase.ovulatory:
        return 'Ovulatoria';
      case CyclePhase.luteal:
        return 'Lútea';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} de ${_monthName(date.month)}';
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      '',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return weekdays[weekday];
  }

  String _monthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month];
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month];
  }

  Color _intensityColor(String intensity) {
    switch (intensity) {
      case 'Alta':
        return AppColors.alert;
      case 'Baja':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _currentDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
