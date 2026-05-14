import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class TipsPreferencesFirestoreService {
  const TipsPreferencesFirestoreService();

  Future<TipsPreferencesData> getPreferences(String uid) async {
    final snapshot = await FirestoreService.tipsPreferencesDoc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return const TipsPreferencesData();
    }

    return TipsPreferencesData.fromMap(snapshot.data()!);
  }

  Future<void> savePreferences(String uid, TipsPreferencesData preferences) {
    return FirestoreService.tipsPreferencesDoc(uid).set(
      preferences.toMap(),
      SetOptions(merge: true),
    );
  }
}
