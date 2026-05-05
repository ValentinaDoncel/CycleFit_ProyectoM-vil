import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/core/services/firebase/cycle_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/onboarding_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/symptoms_firestore_service.dart';
import 'package:cycle_fit/core/services/firebase/workouts_firestore_service.dart';
import 'package:cycle_fit/core/validators/register_validators.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/models/user_model.dart';
import 'package:flutter/material.dart';

enum RegisterStep { account, regularity, symptoms, workout }

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CycleFirestoreService _cycleService = const CycleFirestoreService();
  final SymptomsFirestoreService _symptomsService =
      const SymptomsFirestoreService();
  final WorkoutsFirestoreService _workoutsService =
      const WorkoutsFirestoreService();
  final OnboardingFirestoreService _onboardingService =
      const OnboardingFirestoreService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController lastPeriodController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  UserModel? _newUser;
  RegisterStep _currentStep = RegisterStep.account;
  DateTime? _selectedBirthDate;
  DateTime? _selectedLastPeriodDate;
  String? _periodRegularityKey;
  String? _energyKey;
  final Set<String> _selectedSymptomKeys = {};
  String? _selectedWorkoutCategoryKey;
  String? _selectedWorkoutDetailKey;
  String _selectedWorkoutIntensity = 'Media';
  bool _skipSymptoms = false;
  bool _skipWorkout = false;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  String? get errorMessage => _errorMessage;
  UserModel? get newUser => _newUser;
  RegisterStep get currentStep => _currentStep;
  DateTime? get selectedBirthDate => _selectedBirthDate;
  DateTime? get selectedLastPeriodDate => _selectedLastPeriodDate;
  String? get periodRegularityKey => _periodRegularityKey;
  String? get energyKey => _energyKey;
  String? get selectedWorkoutCategoryKey => _selectedWorkoutCategoryKey;
  String? get selectedWorkoutDetailKey => _selectedWorkoutDetailKey;
  String get selectedWorkoutIntensity => _selectedWorkoutIntensity;
  bool get skipSymptoms => _skipSymptoms;
  bool get skipWorkout => _skipWorkout;

  int get stepIndex => RegisterStep.values.indexOf(_currentStep);
  int get totalSteps => RegisterStep.values.length;
  double get progress => (stepIndex + 1) / totalSteps;
  bool get isFirstStep => _currentStep == RegisterStep.account;
  bool get canSkipCurrentStep =>
      _currentStep == RegisterStep.symptoms || _currentStep == RegisterStep.workout;

  List<RegisterChoice> get regularityOptions => _regularityCatalog
      .map(
        (item) => item.copyWith(isSelected: item.keyName == _periodRegularityKey),
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

  List<RegisterWorkoutCategory> get workoutCategories => _workoutCategories
      .map(
        (item) => item.copyWith(
          isSelected: item.keyName == _selectedWorkoutCategoryKey,
        ),
      )
      .toList();

  List<RegisterWorkoutChoice> get visibleWorkoutChoices {
    if (_selectedWorkoutCategoryKey == null) return const [];
    final category = _workoutCategories.firstWhere(
      (item) => item.keyName == _selectedWorkoutCategoryKey,
    );
    return category.items
        .map(
          (item) => item.copyWith(
            isSelected: item.keyName == _selectedWorkoutDetailKey,
          ),
        )
        .toList();
  }

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

  void toggleSymptom(String key) {
    if (_selectedSymptomKeys.contains(key)) {
      _selectedSymptomKeys.remove(key);
    } else {
      _selectedSymptomKeys.add(key);
    }
    notifyListeners();
  }

  void selectWorkoutCategory(String key) {
    if (_selectedWorkoutCategoryKey == key) return;
    _selectedWorkoutCategoryKey = key;
    _selectedWorkoutDetailKey = null;
    notifyListeners();
  }

  void selectWorkoutDetail(String key) {
    _selectedWorkoutDetailKey = key;
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
        _currentStep = RegisterStep.regularity;
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
        if (_energyKey == null) {
          _errorMessage = 'Selecciona cómo te sientes hoy';
          notifyListeners();
          return false;
        }
        _currentStep = RegisterStep.workout;
        notifyListeners();
        return false;
      case RegisterStep.workout:
        _skipWorkout = false;
        if (_selectedWorkoutCategoryKey == null ||
            _selectedWorkoutDetailKey == null) {
          _errorMessage =
              'Selecciona una categoría y una opción de entrenamiento';
          notifyListeners();
          return false;
        }
        return register();
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
      final birthDate = RegisterValidators.parseUiDate(birthDateController.text);
      final lastPeriodDate =
          RegisterValidators.parseUiDate(lastPeriodController.text);

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
    final firstError = validateNombre(nombreController.text) ??
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
          moodKeys: _energyKey == null ? const [] : [_energyKey!],
          symptomKeys: _selectedSymptomKeys.toList()..sort(),
        ),
      );
    }

    if (!_skipWorkout && _selectedWorkoutDetailKey != null) {
      final workout = _selectedWorkout!;
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

    await _onboardingService.saveStatus(
      userId,
      OnboardingStatusData(
        completedSymptoms: !_skipSymptoms,
        completedWorkout: !_skipWorkout,
        skippedSymptoms: _skipSymptoms,
        skippedWorkout: _skipWorkout,
      ),
    );
  }

  RegisterWorkoutChoice? get _selectedWorkout {
    for (final category in _workoutCategories) {
      for (final item in category.items) {
        if (item.keyName == _selectedWorkoutDetailKey) return item;
      }
    }
    return null;
  }

  String _formatUiDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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
    RegisterChoice(keyName: 'excelente', label: 'Excelente'),
    RegisterChoice(keyName: 'bien', label: 'Bien'),
    RegisterChoice(keyName: 'normal', label: 'Normal'),
    RegisterChoice(keyName: 'regular', label: 'Regular'),
    RegisterChoice(keyName: 'cansada', label: 'Cansada'),
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

  RegisterWorkoutCategory copyWith({bool? isSelected}) {
    return RegisterWorkoutCategory(
      keyName: keyName,
      label: label,
      items: items,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
