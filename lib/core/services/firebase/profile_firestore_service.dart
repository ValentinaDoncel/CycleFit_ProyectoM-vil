import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class ProfileFirestoreService {
  const ProfileFirestoreService();

  Future<UserProfileData> getProfile(String uid) async {
    final snapshot = await FirestoreService.profileDoc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      final initial = UserProfileData.initial();
      await saveProfile(uid, initial);
      return initial;
    }

    return UserProfileData.fromMap(snapshot.data()!);
  }

  Future<void> saveProfile(String uid, UserProfileData profile) {
    return FirestoreService.profileDoc(uid).set(profile.toMap());
  }
}
