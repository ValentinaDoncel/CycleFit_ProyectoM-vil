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

    final credential = await instance.signInAnonymously();
    return credential.user!;
  }
}
