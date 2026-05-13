import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cycle_fit/core/services/firebase/notifications_firestore_service.dart';
import 'package:cycle_fit/models/notification_model.dart';

class NotificationsController extends ChangeNotifier {
  final NotificationsFirestoreService _service = NotificationsFirestoreService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ── Estado ──
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // ── Nueva notificación ──
  final TextEditingController messageController = TextEditingController();
  String _selectedCategory = 'General';
  DateTime? _selectedDateTime;

  // ── Notificaciones (sección recordatorios) ──
  bool _reminderCycle = true;
  bool _reminderSymptoms = true;
  bool _reminderWorkout = false;
  bool _weeklySummary = true;

  // ── Canales de notificación ──
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  DateTime? get selectedDateTime => _selectedDateTime;

  // Getters recordatorios
  bool get reminderCycle => _reminderCycle;
  bool get reminderSymptoms => _reminderSymptoms;
  bool get reminderWorkout => _reminderWorkout;
  bool get weeklySummary => _weeklySummary;

  // Getters canales
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;

  NotificationsController() {
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);
  }

  Future<void> initialize(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _service.getNotifications(uid);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar notificaciones: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Recordatorios (toggles) ──
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

  // ── Canales (toggles) ──
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

Future<void> saveSettings(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Guardar configuración de canales en Firestore
      await _service.saveNotificationSettings(uid, {
        'pushNotifications': _pushNotifications,
        'emailNotifications': _emailNotifications,
        'smsNotifications': _smsNotifications,
        'reminderCycle': _reminderCycle,
        'reminderSymptoms': _reminderSymptoms,
        'reminderWorkout': _reminderWorkout,
        'weeklySummary': _weeklySummary,
      });

      _error = null;
    } catch (e) {
      _error = 'Error al guardar la configuración';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(String uid) async {
    final message = messageController.text.trim();
    final dateTime = _selectedDateTime;

    if (message.isEmpty) {
      _error = 'El mensaje no puede estar vacío';
      notifyListeners();
      return;
    }
    if (dateTime == null) {
      _error = 'Debes seleccionar una fecha y hora';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notification = NotificationModel(
        message: message,
        category: _selectedCategory,
        dateTime: dateTime,
        active: true,
        userId: uid,
      );

      await _service.saveNotification(uid, notification);
      _error = null;

      if (notification.active) {
        await _scheduleLocalNotification(notification);
      }

      messageController.clear();
      _selectedCategory = 'General';
      _selectedDateTime = null;
    } catch (e) {
      _error = 'Error al agregar recordatorio: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<void> _scheduleLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cycle_fit_reminders',
      'Recordatorios CycleFit',
      channelDescription: 'Recordatorios personalizados del bienestar',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime = notification.dateTime;
    final now = DateTime.now();

    if (scheduledTime.isAfter(now)) {
      await _localNotifications.zonedSchedule(
        notification.hashCode,
        '🔔 CycleFit',
        notification.message,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelScheduledNotification(int notificationId) async {
    await _localNotifications.cancel(notificationId);
  }

  Future<void> toggleActive(String uid, NotificationModel notification) async {
    final newActive = !notification.active;
    final updated = notification.copyWith(active: newActive);
    try {
      await _service.updateNotification(uid, updated);
      if (newActive) {
        await _scheduleLocalNotification(updated);
      } else {
        await cancelScheduledNotification(notification.hashCode);
      }
      final index =
          _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = updated;
      }
    } catch (e) {
      _error = 'Error al actualizar: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    try {
      await _service.deleteNotification(uid, notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _error = null;
    } catch (e) {
      _error = 'Error al eliminar: ${e.toString()}';
    }
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}