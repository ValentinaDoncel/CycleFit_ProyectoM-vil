import 'package:firebase_core/firebase_core.dart';

import 'package:cycle_fit/firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer._();

  static Future<FirebaseApp> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
