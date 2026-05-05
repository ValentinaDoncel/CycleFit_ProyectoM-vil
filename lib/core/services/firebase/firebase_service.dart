import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  const FirebaseService._();

  static bool get isInitialized => Firebase.apps.isNotEmpty;

  static FirebaseApp get app => Firebase.app();
}
