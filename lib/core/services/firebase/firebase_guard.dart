import 'package:cycle_fit/core/services/firebase/firebase_service.dart';

class FirebaseGuard {
  const FirebaseGuard._();

  static void ensureInitialized() {
    if (!FirebaseService.isInitialized) {
      throw StateError(
        'Firebase no ha sido inicializado. Ejecuta Firebase.initializeApp() antes de usar los servicios.',
      );
    }
  }
}
