import 'package:flutter/material.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/models/user_model.dart';
import 'package:cycle_fit/core/validators/register_validators.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController lastPeriodController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  UserModel? _newUser;
  DateTime? _selectedBirthDate;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  String? get errorMessage => _errorMessage;
  UserModel? get newUser => _newUser;
  DateTime? get selectedBirthDate => _selectedBirthDate;

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
      birthDateController.text =
          '${date.day}/${date.month}/${date.year}';
    }
    notifyListeners();
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

  String? validateAge(String? value) =>
      RegisterValidators.validateAge(value, birthDate: _selectedBirthDate);

  String? validateLastPeriodDate(String? value) =>
      RegisterValidators.validateLastPeriodDate(value);

  String? validateOptionalNotes(String? value) =>
      RegisterValidators.validateOptionalNotes(value);

  Future<bool> register() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    // Validaciones básicas
    final nombreError = validateNombre(nombreController.text);
    final emailError = validateEmail(emailController.text);
    final passwordError = validatePassword(passwordController.text);
    final confirmError = validateConfirmPassword(confirmPasswordController.text);

    final firstError =
        nombreError ?? emailError ?? passwordError ?? confirmError;
    if (firstError != null) {
      _errorMessage = firstError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      // Validaciones opcionales
      DateTime? birthDate;
      if (birthDateController.text.isNotEmpty) {
        final birthDateError = validateBirthDate(birthDateController.text);
        if (birthDateError != null) {
          _errorMessage = birthDateError;
          _isLoading = false;
          notifyListeners();
          return false;
        }
        birthDate = RegisterValidators.parseUiDate(birthDateController.text);
      }

      DateTime? lastPeriodDate;
      if (lastPeriodController.text.isNotEmpty) {
        final lastPeriodError =
            validateLastPeriodDate(lastPeriodController.text);
        if (lastPeriodError != null) {
          _errorMessage = lastPeriodError;
          _isLoading = false;
          notifyListeners();
          return false;
        }
        lastPeriodDate =
            RegisterValidators.parseUiDate(lastPeriodController.text);
      }

      final notesError = validateOptionalNotes(notesController.text);
      if (notesError != null) {
        _errorMessage = notesError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Registrar usuario
      final user = await _authService.register(
        nombre: nombreController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        fechaNacimiento: birthDate,
        ultimaPeriodo: lastPeriodDate,
        notas: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      _isLoading = false;

      if (user != null) {
        _newUser = user;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Error al registrar el usuario';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearForm() {
    nombreController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    birthDateController.clear();
    ageController.clear();
    lastPeriodController.clear();
    notesController.clear();
    _selectedBirthDate = null;
    _errorMessage = null;
    _newUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    birthDateController.dispose();
    ageController.dispose();
    lastPeriodController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
