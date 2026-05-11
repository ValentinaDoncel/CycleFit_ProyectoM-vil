import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class OnboardingFirestoreService {
  const OnboardingFirestoreService();

  Future<OnboardingStatusData> getStatus(String uid) async {
    final snapshot = await FirestoreService.onboardingDoc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return const OnboardingStatusData();
    }

    return OnboardingStatusData.fromMap(snapshot.data()!);
  }

  Future<void> saveStatus(String uid, OnboardingStatusData status) {
    return FirestoreService.onboardingDoc(uid).set(status.toMap());
  }
}
