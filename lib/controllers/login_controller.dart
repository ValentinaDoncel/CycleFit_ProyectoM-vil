import 'package:flutter/material.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/models/user_model.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Future<bool> login() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final emailError = validateEmail(emailController.text);
    final passwordError = validatePassword(passwordController.text);

    if (emailError != null || passwordError != null) {
      _errorMessage = emailError ?? passwordError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final user = await _authService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      _isLoading = false;

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Email o contraseña incorrectos';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al enviar email de recuperación';
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
