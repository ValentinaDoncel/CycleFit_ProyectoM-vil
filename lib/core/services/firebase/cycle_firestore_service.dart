import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class CycleFirestoreService {
  const CycleFirestoreService();

  Future<CycleData> getCycle(String uid) async {
    final snapshot = await FirestoreService.cycleDoc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      final initial = CycleData.initial();
      await saveCycle(uid, initial);
      return initial;
    }

    return CycleData.fromMap(snapshot.data()!);
  }

  Future<void> saveCycle(String uid, CycleData cycle) {
    return FirestoreService.cycleDoc(uid).set(cycle.toMap());
  }
}
