import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firebase_guard.dart';
import 'package:cycle_fit/core/services/firebase/firebase_paths.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore instance = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    FirebaseGuard.ensureInitialized();
    return instance.collection(FirebasePaths.users).doc(uid);
  }

  static DocumentReference<Map<String, dynamic>> profileDoc(String uid) {
    return userDoc(uid).collection(FirebasePaths.profile).doc('main');
  }

  static DocumentReference<Map<String, dynamic>> cycleDoc(String uid) {
    return userDoc(uid).collection(FirebasePaths.cycles).doc('current');
  }

  static DocumentReference<Map<String, dynamic>> onboardingDoc(String uid) {
    return userDoc(uid).collection(FirebasePaths.profile).doc('onboarding');
  }

  static CollectionReference<Map<String, dynamic>> symptomsCollection(
    String uid,
  ) {
    return userDoc(uid).collection(FirebasePaths.symptoms);
  }

  static CollectionReference<Map<String, dynamic>> workoutsCollection(
    String uid,
  ) {
    return userDoc(uid).collection(FirebasePaths.workouts);
  }

  static CollectionReference<Map<String, dynamic>> feedPostsCollection() {
    FirebaseGuard.ensureInitialized();
    return instance.collection(FirebasePaths.feedPosts);
  }

  static CollectionReference<Map<String, dynamic>> feedCommentsCollection(
    String postId,
  ) {
    return feedPostsCollection().doc(postId).collection('comments');
  }
}
