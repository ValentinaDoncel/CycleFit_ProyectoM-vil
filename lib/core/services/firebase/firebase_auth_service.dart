import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuth instance = FirebaseAuth.instance;

  static User? get currentUser => instance.currentUser;

  static Future<User> ensureSignedIn() async {
    final existingUser = currentUser;
    if (existingUser != null) {
      return existingUser;
    }

    throw StateError('No hay usuario autenticado');
  }
}
