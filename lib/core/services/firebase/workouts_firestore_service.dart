import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class WorkoutsFirestoreService {
  const WorkoutsFirestoreService();

  Future<List<WorkoutData>> getWorkouts(String uid) async {
    final query = await FirestoreService.workoutsCollection(uid)
        .orderBy('date', descending: true)
        .get();

    return query.docs
        .map((doc) => WorkoutData.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addWorkout(String uid, WorkoutData workout) {
    final collection = FirestoreService.workoutsCollection(uid);
    final document = workout.id.isEmpty ? collection.doc() : collection.doc(workout.id);
    return document.set(workout.copyWith(id: document.id).toMap());
  }
}
