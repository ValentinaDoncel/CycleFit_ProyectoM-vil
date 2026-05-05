class RegisterValidators {
  RegisterValidators._();

  static final RegExp _nameRegex =
      RegExp(r"^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s'-]+$");
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  static DateTime? parseUiDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  static String? validateNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    final clean = value.trim();
    if (clean.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (clean.length > 50) {
      return 'El nombre no debe superar 50 caracteres';
    }
    if (!_nameRegex.hasMatch(clean)) {
      return 'Usa solo letras y espacios (sin números)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra mayúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validateBirthDate(String? value) {
    final date = parseUiDate(value);
    if (date == null) {
      return 'Selecciona una fecha de nacimiento válida';
    }
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'La fecha no puede ser futura';
    }
    return null;
  }

  static String? validateAge(String? value, {DateTime? birthDate}) {
    if (value == null || value.trim().isEmpty) {
      return 'La edad es requerida';
    }
    final age = int.tryParse(value.trim());
    if (age == null) return 'Ingresa una edad válida';
    if (age < 13 || age > 100) {
      return 'La edad debe estar entre 13 y 100';
    }

    if (birthDate != null) {
      final now = DateTime.now();
      var expected = now.year - birthDate.year;
      final hasHadBirthdayThisYear = (now.month > birthDate.month) ||
          (now.month == birthDate.month && now.day >= birthDate.day);
      if (!hasHadBirthdayThisYear) expected -= 1;
      if ((expected - age).abs() > 1) {
        return 'La edad no coincide con la fecha de nacimiento';
      }
    }
    return null;
  }

  static String? validateLastPeriodDate(String? value) {
    final date = parseUiDate(value);
    if (date == null) {
      return 'Selecciona una fecha válida';
    }
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'La fecha no puede ser futura';
    }
    if (now.difference(date).inDays > 120) {
      return 'Verifica la fecha: parece demasiado antigua';
    }
    return null;
  }

  static String? validateOptionalNotes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 500) {
      return 'Máximo 500 caracteres';
    }
    return null;
  }
}
