import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  // ── Notification Settings ──
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _reminderCycle = true;
  bool _reminderSymptoms = true;
  bool _reminderWorkout = false;
  bool _weeklySummary = true;

  // ── Privacy & Security ──
  bool _twoFactorAuth = false;
  bool _privateProfile = false;
  bool _shareDataAnalytics = true;
  bool _biometricAuth = false;

  // ── Display Settings ──
  bool _darkMode = false;
  Locale _locale = const Locale('es');
  String _units = 'Métrico (kg, cm)';

  // ── State flags ──
  bool _isSaving = false;
  String? _error;

  // ── Getters ──
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get reminderCycle => _reminderCycle;
  bool get reminderSymptoms => _reminderSymptoms;
  bool get reminderWorkout => _reminderWorkout;
  bool get weeklySummary => _weeklySummary;
  bool get twoFactorAuth => _twoFactorAuth;
  bool get privateProfile => _privateProfile;
  bool get shareDataAnalytics => _shareDataAnalytics;
  bool get biometricAuth => _biometricAuth;
  bool get darkMode => _darkMode;
  Locale get locale => _locale;
  String get language => _locale.languageCode == 'en' ? 'English' : 'Español';
  String get units => _units;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // ── Notification toggles ──
  void togglePushNotifications() {
    _pushNotifications = !_pushNotifications;
    notifyListeners();
  }

  void toggleEmailNotifications() {
    _emailNotifications = !_emailNotifications;
    notifyListeners();
  }

  void toggleSmsNotifications() {
    _smsNotifications = !_smsNotifications;
    notifyListeners();
  }

  void toggleReminderCycle() {
    _reminderCycle = !_reminderCycle;
    notifyListeners();
  }

  void toggleReminderSymptoms() {
    _reminderSymptoms = !_reminderSymptoms;
    notifyListeners();
  }

  void toggleReminderWorkout() {
    _reminderWorkout = !_reminderWorkout;
    notifyListeners();
  }

  void toggleWeeklySummary() {
    _weeklySummary = !_weeklySummary;
    notifyListeners();
  }

  // ── Privacy toggles ──
  void toggleTwoFactorAuth() {
    _twoFactorAuth = !_twoFactorAuth;
    notifyListeners();
  }

  void togglePrivateProfile() {
    _privateProfile = !_privateProfile;
    notifyListeners();
  }

  void toggleShareDataAnalytics() {
    _shareDataAnalytics = !_shareDataAnalytics;
    notifyListeners();
  }

  void toggleBiometricAuth() {
    _biometricAuth = !_biometricAuth;
    notifyListeners();
  }

  // ── Display toggles ──
  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _locale = language == 'English'
        ? const Locale('en')
        : const Locale('es');
    notifyListeners();
  }

  void setUnits(String units) {
    _units = units;
    notifyListeners();
  }

  // ── Save to Firebase ──
  Future<void> saveSettings(String uid) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Simular guardado en Firestore
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Settings saved for user: $uid');
      debugPrint('Push: $_pushNotifications, Email: $_emailNotifications');
      debugPrint('Locale: $_locale');
    } catch (e) {
      _error = 'Error al guardar los ajustes: ${e.toString()}';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}