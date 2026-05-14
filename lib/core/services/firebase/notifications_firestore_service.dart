import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firebase_paths.dart';
import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/notification_model.dart';

class NotificationsFirestoreService {
  const NotificationsFirestoreService();

  CollectionReference<Map<String, dynamic>> _notificationsCollection(
      String uid) {
    return FirestoreService.userDoc(uid).collection(
      FirebasePaths.notifications,
    );
  }

  CollectionReference<Map<String, dynamic>> _settingsCollection(String uid) {
    return FirestoreService.userDoc(uid).collection('notification_settings');
  }

  Future<List<NotificationModel>> getNotifications(String uid) async {
    final snapshot = await _notificationsCollection(uid)
        .orderBy('dateTime', descending: true)
        .get();
return snapshot.docs
         .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
         .toList();
  }

  Future<void> saveNotification(String uid, NotificationModel notification) async {
    if (notification.id != null) {
      await _notificationsCollection(uid)
          .doc(notification.id)
          .update(notification.toMap());
    } else {
      final docRef = _notificationsCollection(uid).doc();
      await docRef.set(notification.copyWith(id: docRef.id).toMap());
    }
  }

  Future<void> updateNotification(String uid, NotificationModel notification) async {
    if (notification.id == null) return;
    await _notificationsCollection(uid)
        .doc(notification.id)
        .update(notification.toMap());
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _notificationsCollection(uid).doc(notificationId).delete();
  }

  Stream<List<NotificationModel>> notificationsStream(String uid) {
return _notificationsCollection(uid)
         .orderBy('dateTime', descending: true)
         .snapshots()
         .map((snapshot) => snapshot.docs
             .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
             .toList());
  }

  /// Guarda la configuración de notificaciones del usuario
  Future<void> saveNotificationSettings(String uid, Map<String, dynamic> settings) {
    return _settingsCollection(uid).doc('preferences').set({
      ...settings,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Carga la configuración de notificaciones del usuario
  Future<Map<String, dynamic>> getNotificationSettings(String uid) async {
    final snapshot = await _settingsCollection(uid).doc('preferences').get();
    if (snapshot.exists) {
      return snapshot.data() ?? {};
    }
    return {};
  }
}