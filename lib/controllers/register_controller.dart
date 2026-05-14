import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/core/services/firebase/cycle_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/onboarding_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/profile_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/symptoms_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/workouts_firestore_service.dart';
import 'package:cycle_fit/core/validators/register_validators.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/models/user_model.dart';
import 'package:flutter/material.dart';

enum RegisterStep {
  account,
  bodyMetrics,
  regularity,
  symptoms,
  mood,
  energy,
  workout,
}

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CycleFirestoreService _cycleService = const CycleFirestoreService();
  final SymptomsFirestoreService _symptomsService =
      const SymptomsFirestoreService();
  final WorkoutsFirestoreService _workoutsService =
      const WorkoutsFirestoreService();
  final OnboardingFirestoreService _onboardingService =
      const OnboardingFirestoreService();
  final ProfileFirestoreService _profileService =
      const ProfileFirestoreService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController lastPeriodController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  UserModel? _newUser;
  RegisterStep _currentStep = RegisterStep.account;
  DateTime? _selectedBirthDate;
  DateTime? _selectedLastPeriodDate;
  String? _periodRegularityKey;
  String? _moodKey;
  String? _energyKey;
  final Set<String> _selectedSymptomKeys = {};
  final Set<String> _selectedWorkoutCategoryKeys = {};
  final Set<String> _selectedWorkoutDetailKeys = {};
  String _selectedWorkoutIntensity = 'Media';
  bool _skipSymptoms = false;
  bool _skipWorkout = false;
  bool _isGoogleOnboarding = false;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  String? get errorMessage => _errorMessage;
  UserModel? get newUser => _newUser;
  RegisterStep get currentStep => _currentStep;
  DateTime? get selectedBirthDate => _selectedBirthDate;
  DateTime? get selectedLastPeriodDate => _selectedLastPeriodDate;
  String? get periodRegularityKey => _periodRegularityKey;
  String? get moodKey => _moodKey;
  String? get energyKey => _energyKey;
  Set<String> get selectedWorkoutCategoryKeys =>
      Set.unmodifiable(_selectedWorkoutCategoryKeys);
  Set<String> get selectedWorkoutDetailKeys =>
      Set.unmodifiable(_selectedWorkoutDetailKeys);
  String get selectedWorkoutIntensity => _selectedWorkoutIntensity;
  bool get skipSymptoms => _skipSymptoms;
  bool get skipWorkout => _skipWorkout;

  int get stepIndex => RegisterStep.values.indexOf(_currentStep);
  int get totalSteps => RegisterStep.values.length;
  double get progress => (stepIndex + 1) / totalSteps;
  bool get isFirstStep =>
      _currentStep == RegisterStep.account ||
      (_isGoogleOnboarding && _currentStep == RegisterStep.bodyMetrics);
  bool get canSkipCurrentStep =>
      _currentStep == RegisterStep.symptoms ||
      _currentStep == RegisterStep.workout;

  List<RegisterChoice> get regularityOptions => _regularityCatalog
      .map(
        (item) =>
            item.copyWith(isSelected: item.keyName == _periodRegularityKey),
      )
      .toList();

  List<RegisterChoice> get symptomChoices => _symptomCatalog
      .map(
        (item) => item.copyWith(
          isSelected: _selectedSymptomKeys.contains(item.keyName),
        ),
      )
      .toList();

  List<RegisterChoice> get energyOptions => _energyCatalog
      .map((item) => item.copyWith(isSelected: item.keyName == _energyKey))
      .toList();

  List<RegisterChoice> get moodOptions => _moodCatalog
      .map((item) => item.copyWith(isSelected: item.keyName == _moodKey))
      .toList();

  List<RegisterWorkoutCategory> get workoutCategories => _workoutCategories
      .map(
        (item) => item.copyWith(
          isSelected: _selectedWorkoutCategoryKeys.contains(item.keyName),
        ),
      )
      .toList();

  List<RegisterWorkoutCategory> get visibleWorkoutCategories =>
      _workoutCategories
          .where((item) => _selectedWorkoutCategoryKeys.contains(item.keyName))
          .map(
            (category) => category.copyWith(
              isSelected: true,
              items: category.items
                  .map(
                    (item) => item.copyWith(
                      isSelected: _selectedWorkoutDetailKeys.contains(
                        item.keyName,
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

  List<String> get intensityChoices => const ['Baja', 'Media', 'Alta'];

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedBirthDate(DateTime? date) {
    _selectedBirthDate = date;
    if (date != null) {
      birthDateController.text = _formatUiDate(date);
    }
    notifyListeners();
  }

  void setSelectedLastPeriodDate(DateTime? date) {
    _selectedLastPeriodDate = date;
    if (date != null) {
      lastPeriodController.text = _formatUiDate(date);
    }
    notifyListeners();
  }

  void selectRegularity(String key) {
    _periodRegularityKey = key;
    notifyListeners();
  }

  void selectEnergy(String key) {
    _energyKey = key;
    notifyListeners();
  }

  void selectMood(String key) {
    _moodKey = key;
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

  void toggleWorkoutCategory(String key) {
    if (_selectedWorkoutCategoryKeys.contains(key)) {
      _selectedWorkoutCategoryKeys.remove(key);
      final category = _workoutCategories.firstWhere(
        (item) => item.keyName == key,
      );
      for (final workout in category.items) {
        _selectedWorkoutDetailKeys.remove(workout.keyName);
      }
    } else {
      _selectedWorkoutCategoryKeys.add(key);
    }
    notifyListeners();
  }

  void toggleWorkoutDetail(String key) {
    if (_selectedWorkoutDetailKeys.contains(key)) {
      _selectedWorkoutDetailKeys.remove(key);
    } else {
      _selectedWorkoutDetailKeys.add(key);
    }
    notifyListeners();
  }

  void selectWorkoutIntensity(String intensity) {
    _selectedWorkoutIntensity = intensity;
    notifyListeners();
  }

  void previousStep() {
    if (isFirstStep) return;
    _currentStep = RegisterStep.values[stepIndex - 1];
    _errorMessage = null;
    notifyListeners();
  }

  void skipCurrentStep() {
    if (_currentStep == RegisterStep.symptoms) {
      _skipSymptoms = true;
      _selectedSymptomKeys.clear();
      _moodKey = null;
      _energyKey = null;
      _currentStep = RegisterStep.workout;
    } else if (_currentStep == RegisterStep.workout) {
      _skipWorkout = true;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> continueFromCurrentStep() async {
    _errorMessage = null;

    switch (_currentStep) {
      case RegisterStep.account:
        if (!_validateAccountStep()) return false;
        _currentStep = RegisterStep.bodyMetrics;
        notifyListeners();
        return false;
      case RegisterStep.bodyMetrics:
        if (!_validateBodyMetricsStep()) return false;
        _currentStep = RegisterStep.regularity;
        if (_isGoogleOnboarding) _currentStep = RegisterStep.symptoms;
        notifyListeners();
        return false;
      case RegisterStep.regularity:
        if (_periodRegularityKey == null) {
          _errorMessage = 'Selecciona si tu periodo es regular';
          notifyListeners();
          return false;
        }
        _currentStep = RegisterStep.symptoms;
        notifyListeners();
        return false;
      case RegisterStep.symptoms:
        _skipSymptoms = false;
        if (_selectedSymptomKeys.isEmpty) {
          _errorMessage = 'Selecciona al menos un síntoma o salta este paso';
          notifyListeners();
          return false;
        }
        _currentStep = RegisterStep.mood;
        notifyListeners();
        return false;
      case RegisterStep.mood:
        if (_moodKey == null) {
          _errorMessage = 'Selecciona tu estado de ánimo';
          notifyListeners();
          return false;
        }
        _currentStep = RegisterStep.energy;
        notifyListeners();
        return false;
      case RegisterStep.energy:
        if (_energyKey == null) {
          _errorMessage = 'Selecciona tu nivel de energía';
          notifyListeners();
          return false;
        }
        _currentStep = RegisterStep.workout;
        notifyListeners();
        return false;
      case RegisterStep.workout:
        _skipWorkout = false;
        if (_selectedWorkoutCategoryKeys.isEmpty ||
            _selectedWorkoutDetailKeys.isEmpty) {
          _errorMessage = 'Selecciona al menos una categoría y un ejercicio';
          notifyListeners();
          return false;
        }
        return finishRegistrationFlow();
    }
  }

  String? validateNombre(String? value) =>
      RegisterValidators.validateNombre(value);

  String? validateEmail(String? value) =>
      RegisterValidators.validateEmail(value);

  String? validatePassword(String? value) =>
      RegisterValidators.validatePassword(value);

  String? validateConfirmPassword(String? value) {
    return RegisterValidators.validateConfirmPassword(
      value,
      passwordController.text,
    );
  }

  String? validateBirthDate(String? value) =>
      RegisterValidators.validateBirthDate(value);

  String? validateLastPeriodDate(String? value) =>
      RegisterValidators.validateLastPeriodDate(value);

  Future<bool> register() async {
    if (!_validateAccountStep()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final birthDate = RegisterValidators.parseUiDate(
        birthDateController.text,
      );
      final lastPeriodDate = RegisterValidators.parseUiDate(
        lastPeriodController.text,
      );

      final user = await _authService.register(
        nombre: nombreController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        fechaNacimiento: birthDate,
        ultimaPeriodo: lastPeriodDate,
        periodoRegular: _periodRegularityKey,
      );

      if (user == null) {
        _errorMessage = 'Error al registrar el usuario';
        return false;
      }

      await _saveOnboardingRecords(
        userId: user.id,
        lastPeriodDate: lastPeriodDate,
      );
      await _saveProfileFromRegistration(user);
      _newUser = user;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _errorMessage = 'No se pudo registrar con Google';
        return false;
      }
      _newUser = user;
      if (!_authService.lastGoogleSignInCreatedUser) {
        return true;
      }
      _isGoogleOnboarding = true;
      _currentStep = RegisterStep.bodyMetrics;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startGoogleOnboardingForCurrentUser() {
    _isGoogleOnboarding = true;
    _currentStep = RegisterStep.bodyMetrics;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> finishRegistrationFlow() {
    return _isGoogleOnboarding ? _finishGoogleOnboarding() : register();
  }

  Future<bool> _finishGoogleOnboarding() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        _errorMessage = 'No se pudo obtener el usuario autenticado';
        return false;
      }
      await _saveOnboardingRecords(
        userId: user.id,
        lastPeriodDate: user.ultimaPeriodo,
      );
      await _saveProfileFromRegistration(user);
      _newUser = user;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateAccountStep() {
    final firstError =
        validateNombre(nombreController.text) ??
        validateEmail(emailController.text) ??
        validatePassword(passwordController.text) ??
        validateConfirmPassword(confirmPasswordController.text);

    if (firstError != null) {
      _errorMessage = firstError;
      notifyListeners();
      return false;
    }

    if (birthDateController.text.isEmpty) {
      _errorMessage = 'Selecciona tu fecha de nacimiento';
      notifyListeners();
      return false;
    }

    final birthDateError = validateBirthDate(birthDateController.text);
    if (birthDateError != null) {
      _errorMessage = birthDateError;
      notifyListeners();
      return false;
    }

    if (lastPeriodController.text.isEmpty) {
      _errorMessage = 'Selecciona la fecha de tu última menstruación';
      notifyListeners();
      return false;
    }

    final lastPeriodError = validateLastPeriodDate(lastPeriodController.text);
    if (lastPeriodError != null) {
      _errorMessage = lastPeriodError;
      notifyListeners();
      return false;
    }

    return true;
  }

bool _validateBodyMetricsStep() {
     final weightText = weightController.text.replaceAll(',', '.');
     final weight = double.tryParse(weightText);
     if (weight == null || weight <= 0 || weight > 350) {
       _errorMessage = 'Ingresa un peso corporal válido (máx. 350 kg)';
       notifyListeners();
       return false;
     }
     final heightText = heightController.text.replaceAll(',', '.');
     final height = double.tryParse(heightText);
     if (height == null || height <= 0 || height > 250) {
       _errorMessage = 'Ingresa una estatura válida en centímetros (máx. 250 cm)';
       notifyListeners();
       return false;
     }
     return true;
   }

  Future<void> _saveProfileFromRegistration(UserModel user) async {
    final existingProfile = await _profileService.getProfile(user.id);
    await _profileService.saveProfile(
      user.id,
      existingProfile.copyWith(
        name: user.nombre.isEmpty ? existingProfile.name : user.nombre,
        email: user.email,
        age: _ageFromBirthDate(user.fechaNacimiento),
        weightKg: double.parse(weightController.text.replaceAll(',', '.')),
        heightCm: double.parse(heightController.text.replaceAll(',', '.')),
        avatarUrl: user.fotoPerfil ?? existingProfile.avatarUrl,
      ),
    );
  }

  Future<void> _saveOnboardingRecords({
    required String userId,
    required DateTime? lastPeriodDate,
  }) async {
    if (lastPeriodDate != null) {
      await _cycleService.saveCycle(
        userId,
        CycleData(periodStartDate: _dateOnly(lastPeriodDate)),
      );
    }

    if (!_skipSymptoms) {
      await _symptomsService.saveRecord(
        userId,
        SymptomRecordData(
          date: _today,
          energyLevel: _energyValueForKey(_energyKey),
          moodKeys: _moodKey == null ? const [] : [_moodKey!],
          symptomKeys: _selectedSymptomKeys.toList()..sort(),
        ),
      );
    }

    if (!_skipWorkout && _selectedWorkoutDetailKeys.isNotEmpty) {
      for (final workout in _selectedWorkouts) {
        await _workoutsService.addWorkout(
          userId,
          WorkoutData(
            id: '',
            title: workout.label,
            intensity: _selectedWorkoutIntensity,
            durationMinutes: workout.durationMinutes,
            calories: workout.calories,
            date: _today,
          ),
        );
      }
    }

    await _onboardingService.saveStatus(
      userId,
      OnboardingStatusData(
        completedSymptoms: !_skipSymptoms,
        completedWorkout: !_skipWorkout,
        skippedSymptoms: _skipSymptoms,
        skippedWorkout: _skipWorkout,
      ),
    );

    await _validateSavedOnboardingRecords(userId);
  }

  Future<void> _validateSavedOnboardingRecords(String userId) async {
    final onboardingStatus = await _onboardingService.getStatus(userId);
    if (onboardingStatus.skippedSymptoms != _skipSymptoms ||
        onboardingStatus.skippedWorkout != _skipWorkout) {
      throw Exception('No se pudo validar el guardado del onboarding');
    }

    final cycle = await _cycleService.getCycle(userId);
    if (cycle.periodStartDate.year < 1900) {
      throw Exception('No se pudo validar el ciclo guardado');
    }

    if (!_skipSymptoms) {
      final symptoms = await _symptomsService.getRecordForDay(userId, _today);
      if (symptoms == null) {
        throw Exception('No se pudo validar el registro de síntomas');
      }
    }

    if (!_skipWorkout && _selectedWorkoutDetailKeys.isNotEmpty) {
      final workouts = await _workoutsService.getWorkouts(userId);
      final selectedTitles = _selectedWorkouts
          .map((item) => item.label)
          .toSet();
      final savedTitles = workouts.map((item) => item.title).toSet();
      if (!selectedTitles.every(savedTitles.contains)) {
        throw Exception('No se pudo validar el entrenamiento guardado');
      }
    }
  }

  List<RegisterWorkoutChoice> get _selectedWorkouts {
    final selected = <RegisterWorkoutChoice>[];
    for (final category in _workoutCategories) {
      for (final item in category.items) {
        if (_selectedWorkoutDetailKeys.contains(item.keyName)) {
          selected.add(item);
        }
      }
    }
    return selected;
  }

  String _formatUiDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthday =
        now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age--;
    return age < 0 ? 0 : age;
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  double _energyValueForKey(String? key) {
    switch (key) {
      case 'excelente':
        return 95;
      case 'bien':
        return 78;
      case 'normal':
        return 60;
      case 'regular':
        return 42;
      case 'cansada':
        return 25;
      default:
        return 60;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    birthDateController.dispose();
    lastPeriodController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  static const List<RegisterChoice> _regularityCatalog = [
    RegisterChoice(keyName: 'si', label: 'Sí'),
    RegisterChoice(keyName: 'no', label: 'No'),
    RegisterChoice(
      keyName: 'prefiere_no_responder',
      label: 'No lo sé/Prefiero no contestar',
    ),
  ];

  static const List<RegisterChoice> _energyCatalog = [
    RegisterChoice(keyName: 'cansada', label: 'Neutra'),
    RegisterChoice(keyName: 'regular', label: 'Baja'),
    RegisterChoice(keyName: 'normal', label: 'Media'),
    RegisterChoice(keyName: 'bien', label: 'Alta'),
    RegisterChoice(keyName: 'excelente', label: 'Eufórica'),
  ];

  static const List<RegisterChoice> _moodCatalog = [
    RegisterChoice(keyName: 'tranquila', label: 'Tranquila'),
    RegisterChoice(keyName: 'feliz', label: 'Feliz'),
    RegisterChoice(keyName: 'sensible', label: 'Sensible'),
    RegisterChoice(keyName: 'ansiosa', label: 'Ansiosa'),
    RegisterChoice(keyName: 'irritable', label: 'Irritable'),
  ];

  static const List<RegisterChoice> _symptomCatalog = [
    RegisterChoice(keyName: 'dolor_cabeza', label: 'Dolor de cabeza'),
    RegisterChoice(keyName: 'fatiga', label: 'Fatiga'),
    RegisterChoice(keyName: 'colicos', label: 'Cólicos'),
    RegisterChoice(keyName: 'dolor_espalda', label: 'Dolor de espalda'),
    RegisterChoice(keyName: 'antojos', label: 'Antojos'),
    RegisterChoice(keyName: 'acne', label: 'Acné'),
    RegisterChoice(keyName: 'sensibilidad_senos', label: 'Senos sensibles'),
    RegisterChoice(keyName: 'insomnio', label: 'Insomnio'),
  ];

  static const List<RegisterWorkoutCategory> _workoutCategories = [
    RegisterWorkoutCategory(
      keyName: 'suave',
      label: 'Suave',
      items: [
        RegisterWorkoutChoice(
          keyName: 'yoga_suave',
          label: 'Yoga suave',
          durationMinutes: 25,
          calories: 90,
        ),
        RegisterWorkoutChoice(
          keyName: 'caminata',
          label: 'Caminata',
          durationMinutes: 30,
          calories: 140,
        ),
      ],
    ),
    RegisterWorkoutCategory(
      keyName: 'fuerza',
      label: 'Fuerza',
      items: [
        RegisterWorkoutChoice(
          keyName: 'tren_superior',
          label: 'Tren superior',
          durationMinutes: 40,
          calories: 230,
        ),
        RegisterWorkoutChoice(
          keyName: 'piernas_gluteos',
          label: 'Piernas y glúteos',
          durationMinutes: 45,
          calories: 280,
        ),
      ],
    ),
    RegisterWorkoutCategory(
      keyName: 'cardio',
      label: 'Cardio',
      items: [
        RegisterWorkoutChoice(
          keyName: 'cardio_moderado',
          label: 'Cardio moderado',
          durationMinutes: 35,
          calories: 260,
        ),
        RegisterWorkoutChoice(
          keyName: 'hiit',
          label: 'HIIT',
          durationMinutes: 20,
          calories: 240,
        ),
      ],
    ),
  ];
}

class RegisterChoice {
  const RegisterChoice({
    required this.keyName,
    required this.label,
    this.isSelected = false,
  });

  final String keyName;
  final String label;
  final bool isSelected;

  RegisterChoice copyWith({bool? isSelected}) {
    return RegisterChoice(
      keyName: keyName,
      label: label,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class RegisterWorkoutChoice {
  const RegisterWorkoutChoice({
    required this.keyName,
    required this.label,
    required this.durationMinutes,
    required this.calories,
    this.isSelected = false,
  });

  final String keyName;
  final String label;
  final int durationMinutes;
  final int calories;
  final bool isSelected;

  RegisterWorkoutChoice copyWith({bool? isSelected}) {
    return RegisterWorkoutChoice(
      keyName: keyName,
      label: label,
      durationMinutes: durationMinutes,
      calories: calories,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class RegisterWorkoutCategory {
  const RegisterWorkoutCategory({
    required this.keyName,
    required this.label,
    required this.items,
    this.isSelected = false,
  });

  final String keyName;
  final String label;
  final List<RegisterWorkoutChoice> items;
  final bool isSelected;

  RegisterWorkoutCategory copyWith({
    bool? isSelected,
    List<RegisterWorkoutChoice>? items,
  }) {
    return RegisterWorkoutCategory(
      keyName: keyName,
      label: label,
      items: items ?? this.items,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
