import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/models/user_model.dart';

class ProfileFirestoreService {
  const ProfileFirestoreService();

  Future<UserProfileData> getProfile(String uid) async {
    final snapshot = await FirestoreService.profileDoc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      final userSnapshot = await FirestoreService.userDoc(uid).get();
      final initial = userSnapshot.exists && userSnapshot.data() != null
          ? _profileFromUser(UserModel.fromJson(userSnapshot.data()!))
          : UserProfileData.initial();
      await saveProfile(uid, initial);
      return initial;
    }

    return UserProfileData.fromMap(snapshot.data()!);
  }

  Future<void> saveProfile(String uid, UserProfileData profile) {
    return FirestoreService.profileDoc(uid).set(profile.toMap());
  }

  UserProfileData _profileFromUser(UserModel user) {
    return UserProfileData(
      name: user.nombre.isEmpty ? 'Usuario' : user.nombre,
      email: user.email,
      age: _ageFromBirthDate(user.fechaNacimiento),
      weightKg: 0,
      heightCm: 0,
      goal: 'Sin definir',
      avatarUrl: user.fotoPerfil ?? '',
    );
  }

  int _ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthday =
        now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age--;
    return age < 0 ? 0 : age;
  }
}
