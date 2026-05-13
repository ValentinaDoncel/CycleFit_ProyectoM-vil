import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationDelegate();

  // ── App ──
  String get appTitle => _localeMap['appTitle'] ?? 'CycleFit';
  String get home => _localeMap['home'] ?? 'Inicio';
  String get cycle => _localeMap['cycle'] ?? 'Ciclo';
  String get symptoms => _localeMap['symptoms'] ?? 'Síntomas';
  String get exercise => _localeMap['exercise'] ?? 'Ejercicio';
  String get feed => _localeMap['feed'] ?? 'Feed';
  String get tips => _localeMap['tips'] ?? 'Tips';
  String get profile => _localeMap['profile'] ?? 'Perfil';
  String get cycleFit => _localeMap['cycleFit'] ?? 'CycleFit';

  // ── Login ──
  String get loginTitle => _localeMap['loginTitle'] ?? 'Welcome Back';
  String get loginSubtitle =>
      _localeMap['loginSubtitle'] ?? 'Sign in to your account';
  String get emailLabel => _localeMap['emailLabel'] ?? 'Email';
  String get emailHint => _localeMap['emailHint'] ?? 'email@example.com';
  String get passwordLabel => _localeMap['passwordLabel'] ?? 'Password';
  String get passwordHint => _localeMap['passwordHint'] ?? 'Enter your password';
  String get loginButton => _localeMap['loginButton'] ?? 'Sign In';
  String get googleLogin =>
      _localeMap['googleLogin'] ?? 'Continue with Google';
  String get forgotPassword =>
      _localeMap['forgotPassword'] ?? 'Forgot password?';
  String get noAccount => _localeMap['noAccount'] ?? "Don't have an account?";
  String get createAccount => _localeMap['createAccount'] ?? 'Create Account';
  String get passwordRecovery =>
      _localeMap['passwordRecovery'] ?? 'Password recovery in development';

  // ── Register ──
  String get createAccountTitle =>
      _localeMap['createAccountTitle'] ?? 'Create Account';
  String get fullNameLabel =>
      _localeMap['fullNameLabel'] ?? 'Full name';
  String get weightLabel =>
      _localeMap['weightLabel'] ?? 'Body weight (kg)';
  String get heightLabel =>
      _localeMap['heightLabel'] ?? 'Height (cm)';
  String get birthDateLabel =>
      _localeMap['birthDateLabel'] ?? 'Date of birth';
  String get lastPeriodLabel =>
      _localeMap['lastPeriodLabel'] ?? 'Last period';
  String get nextButton => _localeMap['nextButton'] ?? 'Next';
  String get finishButton => _localeMap['finishButton'] ?? 'Finish';
  String get registerSuccess =>
      _localeMap['registerSuccess'] ?? 'Registration completed successfully';
  String get periodRegularity =>
      _localeMap['periodRegularity'] ?? 'Is your period regular?';
  String get symptomsTitle =>
      _localeMap['symptomsTitle'] ?? 'What symptoms have you noticed?';
  String get moodTitle => _localeMap['moodTitle'] ?? 'How is your mood?';
  String get energyTitle =>
      _localeMap['energyTitle'] ?? 'How is your energy?';
  String get workoutTitle =>
      _localeMap['workoutTitle'] ?? 'What type of exercise do you do?';
  String get yes => _localeMap['yes'] ?? 'Yes';
  String get no => _localeMap['no'] ?? 'No';
  String get notSure => _localeMap['notSure'] ?? 'Not sure';

  // ── Dashboard ──
  String get noReminders =>
      _localeMap['noReminders'] ?? 'No reminders yet';
  String get createReminder =>
      _localeMap['createReminder'] ?? 'Create a new reminder to get started';
  String get newReminder => _localeMap['newReminder'] ?? 'New Reminder';
  String get categoryLabel => _localeMap['categoryLabel'] ?? 'Category';
  String get dateTimeLabel =>
      _localeMap['dateTimeLabel'] ?? 'Date and time';
  String get selectDateTime =>
      _localeMap['selectDateTime'] ?? 'Select date and time';
  String get addReminder => _localeMap['addReminder'] ?? '+ Add Reminder';
  String get reminderAdded =>
      _localeMap['reminderAdded'] ?? 'Reminder added successfully';

  // ── Notifications Settings ──
  String get notificationSettings =>
      _localeMap['notificationSettings'] ?? 'Notification Settings';
  String get notificationChannels =>
      _localeMap['notificationChannels'] ?? 'Notification Channels';
  String get pushNotifications =>
      _localeMap['pushNotifications'] ?? 'Push Notifications';
  String get pushNotificationsSub =>
      _localeMap['pushNotificationsSub'] ?? 'Receive real-time alerts';
  String get emailNotifications =>
      _localeMap['emailNotifications'] ?? 'Email Notifications';
  String get emailNotificationsSub =>
      _localeMap['emailNotificationsSub'] ??
      'Weekly summary and important alerts';
  String get smsNotifications =>
      _localeMap['smsNotifications'] ?? 'SMS Notifications';
  String get smsNotificationsSub =>
      _localeMap['smsNotificationsSub'] ??
      'Critical alerts about your cycle';
  String get reminders => _localeMap['reminders'] ?? 'Reminders';
  String get cycleReminder =>
      _localeMap['cycleReminder'] ?? 'Cycle Reminder';
  String get cycleReminderSub =>
      _localeMap['cycleReminderSub'] ??
      'Notifies you about your phase and period';
  String get symptomReminder =>
      _localeMap['symptomReminder'] ?? 'Symptom Reminder';
  String get symptomReminderSub =>
      _localeMap['symptomReminderSub'] ??
      "Don't forget to log your symptoms";
  String get workoutReminder =>
      _localeMap['workoutReminder'] ?? 'Workout Reminder';
  String get workoutReminderSub =>
      _localeMap['workoutReminderSub'] ?? 'Motivation for your training';
  String get weeklySummary =>
      _localeMap['weeklySummary'] ?? 'Weekly Summary';
  String get weeklySummarySub =>
      _localeMap['weeklySummarySub'] ?? 'Receive a summary of your week';
  String get saveSettings =>
      _localeMap['saveSettings'] ?? 'Save Changes';
  String get savedSettings =>
      _localeMap['savedSettings'] ?? 'Settings saved';

  // ── Settings Page ──
  String get settingsTitle => _localeMap['settingsTitle'] ?? 'Settings';
  String get appearance => _localeMap['appearance'] ?? 'Appearance';
  String get darkMode => _localeMap['darkMode'] ?? 'Theme';
  String get darkModeOn => _localeMap['darkModeOn'] ?? 'Dark';
  String get darkModeOff => _localeMap['darkModeOff'] ?? 'Light';
  String get language => _localeMap['language'] ?? 'Language';
  String get appLanguage => _localeMap['appLanguage'] ?? 'App Language';
  String get units => _localeMap['units'] ?? 'Units';
  String get measurementSystem =>
      _localeMap['measurementSystem'] ?? 'Measurement System';
  String get selectLanguage =>
      _localeMap['selectLanguage'] ?? 'Select Language';
  String get selectUnits => _localeMap['selectUnits'] ?? 'Units of Measure';
  String get cancel => _localeMap['cancel'] ?? 'Cancel';
  String get save => _localeMap['save'] ?? 'Save';
  String get languageChanged =>
      _localeMap['languageChanged'] ?? 'Language changed to:';
  String get unitsUpdated =>
      _localeMap['unitsUpdated'] ?? 'Units updated';
  String get metric => _localeMap['metric'] ?? 'Metric (kg, cm)';
  String get imperial => _localeMap['imperial'] ?? 'Imperial (lb, in)';
  String get spanish => _localeMap['spanish'] ?? 'Español';
  String get english => _localeMap['english'] ?? 'English';
  String get portuguese => _localeMap['portuguese'] ?? 'Português';
  String get darkThemeActivated =>
      _localeMap['darkThemeActivated'] ?? 'Dark theme activated';
  String get lightThemeActivated =>
      _localeMap['lightThemeActivated'] ?? 'Light theme activated';

  // ── Profile ──
  String get editProfile => _localeMap['editProfile'] ?? 'Edit';
  String get personalInfo =>
      _localeMap['personalInfo'] ?? 'Personal Information';
  String get nameLabel => _localeMap['nameLabel'] ?? 'Full Name';
  String get emailLabel2 => _localeMap['emailLabel2'] ?? 'Email';
  String get ageLabel => _localeMap['ageLabel'] ?? 'Age';
  String get weightLabel2 => _localeMap['weightLabel2'] ?? 'Weight';
  String get heightLabel2 => _localeMap['heightLabel2'] ?? 'Height';
  String get goalLabel => _localeMap['goalLabel'] ?? 'Main goal';
  String get saveProfile => _localeMap['saveProfile'] ?? 'Save';
  String get cancel2 => _localeMap['cancel2'] ?? 'Cancel';

  // ── Privacy & Security ──
  String get privacyTitle =>
      _localeMap['privacyTitle'] ?? 'Privacy & Security';
  String get accountSection =>
      _localeMap['accountSection'] ?? 'Account';
  String get twoFactorAuth =>
      _localeMap['twoFactorAuth'] ?? 'Two-Factor Authentication';
  String get twoFactorSub =>
      _localeMap['twoFactorSub'] ?? 'Add an extra layer of security';
  String get biometricAuth =>
      _localeMap['biometricAuth'] ?? 'Biometric Authentication';
  String get biometricSub =>
      _localeMap['biometricSub'] ?? 'Use fingerprint or facial recognition';
  String get changePassword =>
      _localeMap['changePassword'] ?? 'Change Password';
  String get changePasswordSub =>
      _localeMap['changePasswordSub'] ?? 'Update your login password';
  String get changeEmail => _localeMap['changeEmail'] ?? 'Change Email';
  String get changeEmailSub =>
      _localeMap['changeEmailSub'] ?? 'Update your email address';
  String get privacySection => _localeMap['privacySection'] ?? 'Privacy';
  String get privateProfile =>
      _localeMap['privateProfile'] ?? 'Private Profile';
  String get privateProfileSub =>
      _localeMap['privateProfileSub'] ?? 'Hide your profile from other users';
  String get analyticsData =>
      _localeMap['analyticsData'] ?? 'Usage & Analytics';
  String get analyticsSub =>
      _localeMap['analyticsSub'] ?? 'Share anonymous data to improve the app';
  String get deleteAccount =>
      _localeMap['deleteAccount'] ?? 'Delete My Account';
  String get deleteAccountSub =>
      _localeMap['deleteAccountSub'] ??
      'Permanently delete your account and all data';
  String get dataSection => _localeMap['dataSection'] ?? 'Data';
  String get exportData => _localeMap['exportData'] ?? 'Export My Data';
  String get exportDataSub =>
      _localeMap['exportDataSub'] ?? 'Download a copy of your data';
  String get importData => _localeMap['importData'] ?? 'Import Data';
  String get importDataSub =>
      _localeMap['importDataSub'] ?? 'Restore data from backup';
  String get featureInProgress =>
      _localeMap['featureInProgress'] ??
      'Feature in development. Coming soon.';

  // ── Change Password Dialog ──
  String get changePasswordTitle =>
      _localeMap['changePasswordTitle'] ?? 'Change Password';
  String get passwordInstructions =>
      _localeMap['passwordInstructions'] ??
      'Enter your current password and the new password.';
  String get currentPassword =>
      _localeMap['currentPassword'] ?? 'Current Password';
  String get newPassword => _localeMap['newPassword'] ?? 'New Password';
  String get confirmPassword =>
      _localeMap['confirmPassword'] ?? 'Confirm Password';
  String get updatePassword =>
      _localeMap['updatePassword'] ?? 'Update';
  String get allFieldsRequired =>
      _localeMap['allFieldsRequired'] ?? 'All fields are required';
  String get passwordMinLength =>
      _localeMap['passwordMinLength'] ??
      'Password must be at least 6 characters';
  String get passwordsDontMatch =>
      _localeMap['passwordsDontMatch'] ?? 'Passwords do not match';

  // ── Change Email ──
  String get changeEmailTitle =>
      _localeMap['changeEmailTitle'] ?? 'Change Email';
  String get changeEmailSubtitle =>
      _localeMap['changeEmailSubtitle'] ??
      'Confirm your current password and the new email. A verification link will be sent.';
  String get newEmailLabel =>
      _localeMap['newEmailLabel'] ?? 'New email address';
  String get currentPasswordLabel =>
      _localeMap['currentPasswordLabel'] ?? 'Current password';
  String get updateEmail => _localeMap['updateEmail'] ?? 'Update Email';
  String get emailUpdated =>
      _localeMap['emailUpdated'] ?? 'Check your new email to verify the change';
  String get clickVerificationLink =>
      _localeMap['clickVerificationLink'] ??
      'Click the verification link.';

  // ── Help & Support ──
  String get helpTitle => _localeMap['helpTitle'] ?? 'Help & Support';
  String get faqTitle => _localeMap['faqTitle'] ?? 'Frequently Asked Questions';
  String get contactTitle => _localeMap['contactTitle'] ?? 'Contact';
  String get reportProblem =>
      _localeMap['reportProblem'] ?? 'Report a Problem';
  String get reportProblemSub =>
      _localeMap['reportProblemSub'] ?? 'Found a bug? Help us improve.';
  String get sendReport => _localeMap['sendReport'] ?? 'Send Report';
  String get supportEmail =>
      _localeMap['supportEmail'] ?? 'support@cyclefit.app';
  String get liveChat => _localeMap['liveChat'] ?? 'Live Chat';
  String get liveChatHours =>
      _localeMap['liveChatHours'] ?? 'Available 8am - 8pm';
  String get helpCenter => _localeMap['helpCenter'] ?? 'Help Center';
  String get helpCenterSub =>
      _localeMap['helpCenterSub'] ?? 'Visit our help center';

  // ── About ──
  String get aboutTitle => _localeMap['aboutTitle'] ?? 'About';
  String get aboutDescription => _localeMap['aboutDescription'] ??
      'CycleFit is a menstrual cycle tracking app designed to help you better understand your body. '
      'Track your symptoms, control your cycle, receive personalized AI-based recommendations and '
      'connect with a supportive community.';
  String get featuresTitle =>
      _localeMap['featuresTitle'] ?? 'Main Features';
  String get cycleTracking =>
      _localeMap['cycleTracking'] ?? 'Cycle Tracking';
  String get cycleTrackingSub =>
      _localeMap['cycleTrackingSub'] ?? 'Track and predict your menstrual cycle';
  String get symptomTracking =>
      _localeMap['symptomTracking'] ?? 'Symptom Tracking';
  String get symptomTrackingSub =>
      _localeMap['symptomTrackingSub'] ??
      'Keep a detailed diary of your symptoms';
  String get exerciseRecommendations =>
      _localeMap['exerciseRecommendations'] ?? 'Exercise Recommendations';
  String get exerciseRecommendationsSub =>
      _localeMap['exerciseRecommendationsSub'] ??
      'Train according to your cycle phase';
  String get aiTips => _localeMap['aiTips'] ?? 'AI Tips';
  String get aiTipsSub =>
      _localeMap['aiTipsSub'] ?? 'Smart personalized recommendations';
  String get community => _localeMap['community'] ?? 'Community';
  String get communitySub =>
      _localeMap['communitySub'] ?? 'Share and connect in the feed';
  String get dailyTips => _localeMap['dailyTips'] ?? 'Daily Tips';
  String get dailyTipsSub =>
      _localeMap['dailyTipsSub'] ?? 'Nutrition, rest and wellness';
  String get license => _localeMap['license'] ?? 'License';
  String get copyright => _localeMap['copyright'] ??
      '© 2026 CycleFit. All rights reserved.';
  String get version => _localeMap['version'] ?? 'CycleFit v1.0.0';

  // ── Home ──
  String get continueBtn => _localeMap['continueBtn'] ?? 'Continue';
  String get skip => _localeMap['skip'] ?? 'Skip';
  String get nextTip => _localeMap['nextTip'] ?? 'Next tip';
  String get previousTip => _localeMap['previousTip'] ?? 'Previous';
  String get seeAllNotifications =>
      _localeMap['seeAllNotifications'] ?? 'See all notifications';

  // ── Feedback ──
  String get noNotificationsTitle =>
      _localeMap['noNotificationsTitle'] ?? 'No Notifications';
  String get noNotificationsSub =>
      _localeMap['noNotificationsSub'] ??
      'When there are notifications, they will appear here';

  Map<String, String> get _localeMap {
    final maps = <String, Map<String, String>>{
      'es': {
        'appTitle': 'CycleFit',
        'home': 'Inicio',
        'cycle': 'Ciclo',
        'symptoms': 'Síntomas',
        'exercise': 'Ejercicio',
        'feed': 'Feed',
        'tips': 'Tips',
        'profile': 'Perfil',
        'cycleFit': 'CycleFit',
        'loginTitle': 'Inicia sesión',
        'loginSubtitle': 'Inicia sesión en tu cuenta',
        'emailLabel': 'Email',
        'emailHint': 'correo@ejemplo.com',
        'passwordLabel': 'Contraseña',
        'passwordHint': 'Ingresa tu contraseña',
        'loginButton': 'Iniciar Sesión',
        'googleLogin': 'Continuar con Google',
        'forgotPassword': '¿Olvidaste tu contraseña?',
        'noAccount': '¿No tienes cuenta?',
        'createAccount': 'Crear Nueva Cuenta',
        'passwordRecovery': 'Función de recuperación en desarrollo',
        'createAccountTitle': 'Crea tu cuenta',
        'fullNameLabel': 'Nombre completo',
        'weightLabel': 'Peso corporal (kg)',
        'heightLabel': 'Estatura (cm)',
        'birthDateLabel': 'Fecha de nacimiento',
        'lastPeriodLabel': 'Última menstruación',
        'nextButton': 'Siguiente',
        'finishButton': 'Finalizar',
        'registerSuccess': 'Registro completado correctamente',
        'periodRegularity': '¿Es tu periodo regular?',
        'symptomsTitle': '¿Qué síntomas has notado?',
        'moodTitle': '¿Cuál es tu estado de ánimo?',
        'energyTitle': '¿Cómo está tu energía?',
        'workoutTitle': '¿Qué tipo de entrenamiento realizas?',
        'yes': 'Sí',
        'no': 'No',
        'notSure': 'No lo sé',
        'noReminders': 'No tienes recordatorios',
        'createReminder': 'Crea un nuevo recordatorio para empezar',
        'newReminder': 'Nuevo recordatorio',
        'categoryLabel': 'Categoría',
        'dateTimeLabel': 'Fecha y hora',
        'selectDateTime': 'Seleccionar fecha y hora',
        'addReminder': '+ Agregar recordatorio',
        'reminderAdded': 'Recordatorio agregado correctamente',
        'notificationSettings': 'Configuración de notificaciones',
        'notificationChannels': 'Canales de notificación',
        'pushNotifications': 'Notificaciones push',
        'pushNotificationsSub': 'Recibe alertas en tiempo real',
        'emailNotifications': 'Notificaciones por email',
        'emailNotificationsSub': 'Resumen semanal y alertas importantes',
        'smsNotifications': 'Notificaciones SMS',
        'smsNotificationsSub': 'Alertas críticas sobre tu ciclo',
        'reminders': 'Recordatorios',
        'cycleReminder': 'Recordatorio de ciclo',
        'cycleReminderSub': 'Te avisa sobre tu fase y período',
        'symptomReminder': 'Recordatorio de síntomas',
        'symptomReminderSub': 'No olvides registrar tus síntomas',
        'workoutReminder': 'Recordatorio de ejercicio',
        'workoutReminderSub': 'Motivación para tu entrenamiento',
        'weeklySummary': 'Resumen semanal',
        'weeklySummarySub': 'Recibe un resumen de tu semana',
        'saveSettings': 'Guardar cambios',
        'savedSettings': 'Configuración guardada',
        'settingsTitle': 'Ajustes',
        'appearance': 'Apariencia',
        'darkMode': 'Tema',
        'darkModeOn': 'Oscuro',
        'darkModeOff': 'Claro',
        'language': 'Idioma',
        'appLanguage': 'Idioma de la app',
        'units': 'Unidades',
        'measurementSystem': 'Sistema de medidas',
        'selectLanguage': 'Seleccionar idioma',
        'selectUnits': 'Unidades de medida',
        'cancel': 'Cancelar',
        'save': 'Guardar',
        'languageChanged': 'Idioma cambiado a:',
        'unitsUpdated': 'Unidades actualizadas',
        'metric': 'Métrico (kg, cm)',
        'imperial': 'Imperial (lb, in)',
        'spanish': 'Español',
        'english': 'English',
        'portuguese': 'Português',
        'darkThemeActivated': 'Tema oscuro activado',
        'lightThemeActivated': 'Tema claro activado',
        'editProfile': 'Editar',
        'personalInfo': 'Información personal',
        'nameLabel': 'Nombre completo',
        'emailLabel2': 'Email',
        'ageLabel': 'Edad',
        'weightLabel2': 'Peso',
        'heightLabel2': 'Estatura',
        'goalLabel': 'Objetivo principal',
        'saveProfile': 'Guardar',
        'cancel2': 'Cancelar',
        'privacyTitle': 'Privacidad y seguridad',
        'accountSection': 'Cuenta',
        'twoFactorAuth': 'Verificación en dos pasos',
        'twoFactorSub': 'Agrega una capa extra de seguridad',
        'biometricAuth': 'Autenticación biométrica',
        'biometricSub': 'Usa huella o reconocimiento facial',
        'changePassword': 'Cambiar contraseña',
        'changePasswordSub': 'Actualiza tu contraseña de acceso',
        'changeEmail': 'Cambiar email',
        'changeEmailSub': 'Actualiza tu correo electrónico',
        'privacySection': 'Privacidad',
        'privateProfile': 'Perfil privado',
        'privateProfileSub': 'Oculta tu perfil de otros usuarios',
        'analyticsData': 'Datos de uso y analítica',
        'analyticsSub': 'Comparte datos anónimos para mejorar la app',
        'deleteAccount': 'Eliminar mi cuenta',
        'deleteAccountSub': 'Elimina permanentemente tu cuenta y datos',
        'dataSection': 'Datos',
        'exportData': 'Exportar mis datos',
        'exportDataSub': 'Descarga una copia de tus datos',
        'importData': 'Importar datos',
        'importDataSub': 'Restaura datos desde un respaldo',
        'featureInProgress': 'Función en desarrollo. Pronto disponible.',
        'changePasswordTitle': 'Cambiar contraseña',
        'passwordInstructions':
            'Ingresa tu contraseña actual y la nueva contraseña.',
        'currentPassword': 'Contraseña actual',
        'newPassword': 'Nueva contraseña',
        'confirmPassword': 'Confirmar nueva contraseña',
        'updatePassword': 'Actualizar',
        'allFieldsRequired': 'Todos los campos son obligatorios',
        'passwordMinLength': 'La contraseña debe tener al menos 6 caracteres',
        'passwordsDontMatch': 'Las contraseñas no coinciden',
        'changeEmailTitle': 'Cambiar email',
        'changeEmailSubtitle':
            'Confirma tu contraseña actual y el nuevo correo. Se enviará un enlace de verificación.',
        'newEmailLabel': 'Nuevo correo electrónico',
        'currentPasswordLabel': 'Contraseña actual',
        'updateEmail': 'Actualizar email',
        'emailUpdated': 'Revisa tu nuevo correo para verificar el cambio',
        'clickVerificationLink': 'Haz clic en el enlace de verificación.',
        'helpTitle': 'Ayuda y soporte',
        'faqTitle': 'Preguntas frecuentes',
        'contactTitle': 'Contacto',
        'reportProblem': 'Reportar un problema',
        'reportProblemSub':
            '¿Encontraste un error? Ayúdanos a mejorar.',
        'sendReport': 'Enviar reporte',
        'supportEmail': 'soporte@cyclefit.app',
        'liveChat': 'Chat en vivo',
        'liveChatHours': 'Disponible de 8am - 8pm',
        'helpCenter': 'Centro de ayuda web',
        'helpCenterSub': 'Visita nuestro centro de ayuda',
        'aboutTitle': 'Acerca de',
        'aboutDescription':
            'CycleFit es una aplicación de seguimiento del ciclo menstrual diseñada para ayudarte a entender mejor tu cuerpo. '
            'Registra tus síntomas, controla tu ciclo, recibe recomendaciones personalizadas basadas en inteligencia artificial y '
            'conecta con una comunidad de apoyo.',
        'featuresTitle': 'Características principales',
        'cycleTracking': 'Seguimiento del ciclo',
        'cycleTrackingSub': 'Registra y predice tu ciclo menstrual',
        'symptomTracking': 'Registro de síntomas',
        'symptomTrackingSub': 'Lleva un diario detallado de tus síntomas',
        'exerciseRecommendations': 'Recomendaciones de ejercicio',
        'exerciseRecommendationsSub': 'Entrena según tu fase del ciclo',
        'aiTips': 'Consejos con IA',
        'aiTipsSub': 'Recomendaciones inteligentes personalizadas',
        'community': 'Comunidad',
        'communitySub': 'Comparte y conecta en el feed',
        'dailyTips': 'Tips diarios',
        'dailyTipsSub': 'Nutrición, descanso y bienestar',
        'license': 'Licencia',
        'copyright': '© 2026 CycleFit. Todos los derechos reservados.',
        'version': 'Cyclofit v1.0.0',
        'continueBtn': 'Continuar',
        'skip': 'Saltar',
        'nextTip': 'Siguiente consejo',
        'previousTip': 'Anterior',
        'seeAllNotifications': 'Ver todas las notificaciones',
        'noNotificationsTitle': 'Sin notificaciones',
        'noNotificationsSub':
            'Cuando haya notificaciones, aparecerán aquí',
      },
      'en': {
        'appTitle': 'CycleFit',
        'home': 'Home',
        'cycle': 'Cycle',
        'symptoms': 'Symptoms',
        'exercise': 'Exercise',
        'feed': 'Feed',
        'tips': 'Tips',
        'profile': 'Profile',
        'cycleFit': 'CycleFit',
        'loginTitle': 'Welcome Back',
        'loginSubtitle': 'Sign in to your account',
        'emailLabel': 'Email',
        'emailHint': 'email@example.com',
        'passwordLabel': 'Password',
        'passwordHint': 'Enter your password',
        'loginButton': 'Sign In',
        'googleLogin': 'Continue with Google',
        'forgotPassword': 'Forgot password?',
        'noAccount': "Don't have an account?",
        'createAccount': 'Create Account',
        'passwordRecovery': 'Password recovery in development',
        'createAccountTitle': 'Create Account',
        'fullNameLabel': 'Full name',
        'weightLabel': 'Body weight (kg)',
        'heightLabel': 'Height (cm)',
        'birthDateLabel': 'Date of birth',
        'lastPeriodLabel': 'Last period',
        'nextButton': 'Next',
        'finishButton': 'Finish',
        'registerSuccess': 'Registration completed successfully',
        'periodRegularity': 'Is your period regular?',
        'symptomsTitle': 'What symptoms have you noticed?',
        'moodTitle': 'How is your mood?',
        'energyTitle': 'How is your energy?',
        'workoutTitle': 'What type of exercise do you do?',
        'yes': 'Yes',
        'no': 'No',
        'notSure': 'Not sure',
        'noReminders': 'No reminders yet',
        'createReminder': 'Create a new reminder to get started',
        'newReminder': 'New Reminder',
        'categoryLabel': 'Category',
        'dateTimeLabel': 'Date and time',
        'selectDateTime': 'Select date and time',
        'addReminder': '+ Add Reminder',
        'reminderAdded': 'Reminder added successfully',
        'notificationSettings': 'Notification Settings',
        'notificationChannels': 'Notification Channels',
        'pushNotifications': 'Push Notifications',
        'pushNotificationsSub': 'Receive real-time alerts',
        'emailNotifications': 'Email Notifications',
        'emailNotificationsSub': 'Weekly summary and important alerts',
        'smsNotifications': 'SMS Notifications',
        'smsNotificationsSub': 'Critical alerts about your cycle',
        'reminders': 'Reminders',
        'cycleReminder': 'Cycle Reminder',
        'cycleReminderSub': 'Notifies you about your phase and period',
        'symptomReminder': 'Symptom Reminder',
        'symptomReminderSub': "Don't forget to log your symptoms",
        'workoutReminder': 'Workout Reminder',
        'workoutReminderSub': 'Motivation for your training',
        'weeklySummary': 'Weekly Summary',
        'weeklySummarySub': 'Receive a summary of your week',
        'saveSettings': 'Save Changes',
        'savedSettings': 'Settings saved',
        'settingsTitle': 'Settings',
        'appearance': 'Appearance',
        'darkMode': 'Theme',
        'darkModeOn': 'Dark',
        'darkModeOff': 'Light',
        'language': 'Language',
        'appLanguage': 'App Language',
        'units': 'Units',
        'measurementSystem': 'Measurement System',
        'selectLanguage': 'Select Language',
        'selectUnits': 'Units of Measure',
        'cancel': 'Cancel',
        'save': 'Save',
        'languageChanged': 'Language changed to:',
        'unitsUpdated': 'Units updated',
        'metric': 'Metric (kg, cm)',
        'imperial': 'Imperial (lb, in)',
        'spanish': 'Español',
        'english': 'English',
        'portuguese': 'Português',
        'darkThemeActivated': 'Dark theme activated',
        'lightThemeActivated': 'Light theme activated',
        'editProfile': 'Edit',
        'personalInfo': 'Personal Information',
        'nameLabel': 'Full Name',
        'emailLabel2': 'Email',
        'ageLabel': 'Age',
        'weightLabel2': 'Weight',
        'heightLabel2': 'Height',
        'goalLabel': 'Main goal',
        'saveProfile': 'Save',
        'cancel2': 'Cancel',
        'privacyTitle': 'Privacy & Security',
        'accountSection': 'Account',
        'twoFactorAuth': 'Two-Factor Authentication',
        'twoFactorSub': 'Add an extra layer of security',
        'biometricAuth': 'Biometric Authentication',
        'biometricSub': 'Use fingerprint or facial recognition',
        'changePassword': 'Change Password',
        'changePasswordSub': 'Update your login password',
        'changeEmail': 'Change Email',
        'changeEmailSub': 'Update your email address',
        'privacySection': 'Privacy',
        'privateProfile': 'Private Profile',
        'privateProfileSub': 'Hide your profile from other users',
        'analyticsData': 'Usage & Analytics',
        'analyticsSub': 'Share anonymous data to improve the app',
        'deleteAccount': 'Delete My Account',
        'deleteAccountSub':
            'Permanently delete your account and all data',
        'dataSection': 'Data',
        'exportData': 'Export My Data',
        'exportDataSub': 'Download a copy of your data',
        'importData': 'Import Data',
        'importDataSub': 'Restore data from backup',
        'featureInProgress':
            'Feature in development. Coming soon.',
        'changePasswordTitle': 'Change Password',
        'passwordInstructions':
            'Enter your current password and the new password.',
        'currentPassword': 'Current Password',
        'newPassword': 'New Password',
        'confirmPassword': 'Confirm Password',
        'updatePassword': 'Update',
        'allFieldsRequired': 'All fields are required',
        'passwordMinLength':
            'Password must be at least 6 characters',
        'passwordsDontMatch': 'Passwords do not match',
        'changeEmailTitle': 'Change Email',
        'changeEmailSubtitle':
            'Confirm your current password and the new email. A verification link will be sent.',
        'newEmailLabel': 'New email address',
        'currentPasswordLabel': 'Current password',
        'updateEmail': 'Update Email',
        'emailUpdated':
            'Check your new email to verify the change',
        'clickVerificationLink':
            'Click the verification link.',
        'helpTitle': 'Help & Support',
        'faqTitle': 'Frequently Asked Questions',
        'contactTitle': 'Contact',
        'reportProblem': 'Report a Problem',
        'reportProblemSub':
            'Found a bug? Help us improve.',
        'sendReport': 'Send Report',
        'supportEmail': 'support@cyclefit.app',
        'liveChat': 'Live Chat',
        'liveChatHours': 'Available 8am - 8pm',
        'helpCenter': 'Help Center',
        'helpCenterSub': 'Visit our help center',
        'aboutTitle': 'About',
        'aboutDescription':
            'CycleFit is a menstrual cycle tracking app designed to help you better understand your body. '
            'Track your symptoms, control your cycle, receive personalized AI-based recommendations and '
            'connect with a supportive community.',
        'featuresTitle': 'Main Features',
        'cycleTracking': 'Cycle Tracking',
        'cycleTrackingSub': 'Track and predict your menstrual cycle',
        'symptomTracking': 'Symptom Tracking',
        'symptomTrackingSub':
            'Keep a detailed diary of your symptoms',
        'exerciseRecommendations': 'Exercise Recommendations',
        'exerciseRecommendationsSub':
            'Train according to your cycle phase',
        'aiTips': 'AI Tips',
        'aiTipsSub':
            'Smart personalized recommendations',
        'community': 'Community',
        'communitySub': 'Share and connect in the feed',
        'dailyTips': 'Daily Tips',
        'dailyTipsSub': 'Nutrition, rest and wellness',
        'license': 'License',
        'copyright':
            '© 2026 CycleFit. All rights reserved.',
        'version': 'CycleFit v1.0.0',
        'continueBtn': 'Continue',
        'skip': 'Skip',
        'nextTip': 'Next tip',
        'previousTip': 'Previous',
        'seeAllNotifications': 'See all notifications',
        'noNotificationsTitle': 'No Notifications',
        'noNotificationsSub':
            'When there are notifications, they will appear here',
      },
    };
    return maps[locale.languageCode] ?? maps['es']!;
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}