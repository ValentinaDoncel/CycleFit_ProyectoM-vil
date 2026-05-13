import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firebase_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cycle_fit/models/user_model.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _googleSignInInitialized = false;
  bool _lastGoogleSignInCreatedUser = false;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _firebaseAuth.currentUser != null;
  bool get lastGoogleSignInCreatedUser => _lastGoogleSignInCreatedUser;

  /// Obtener el usuario actual del stream de Firebase Auth
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Obtener el usuario actual de Firebase Auth
  User? get firebaseUser => _firebaseAuth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirebasePaths.users);

  /// Registrar nuevo usuario con email y contraseña
  Future<UserModel?> register({
    required String nombre,
    required String email,
    required String password,
    DateTime? fechaNacimiento,
    DateTime? ultimaPeriodo,
    String? periodoRegular,
    String? notas,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      if (await emailExists(normalizedEmail)) {
        throw Exception('Este email ya está registrado');
      }

      // Crear usuario en Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // Crear documento en Firestore
      final nuevoUsuario = UserModel(
        id: uid,
        nombre: nombre.trim(),
        email: normalizedEmail,
        fechaNacimiento: fechaNacimiento,
        ultimaPeriodo: ultimaPeriodo,
        periodoRegular: periodoRegular,
        notas: notas,
        emailVerificado: credential.user?.emailVerified ?? false,
        proveedorAuth: 'password',
      );

      await _usersCollection.doc(uid).set(nuevoUsuario.toJson());
      await credential.user?.sendEmailVerification();

      _currentUser = nuevoUsuario;
      return nuevoUsuario;
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth
      if (e.code == 'weak-password') {
        throw Exception('La contraseña es muy débil');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Este email ya está registrado');
      } else if (e.code == 'invalid-email') {
        throw Exception('El email no es válido');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('No se pudo obtener el usuario autenticado');
      }

      await _ensureValidToken(firebaseUser);
      await firebaseUser.reload();
      final reloadedUser = _firebaseAuth.currentUser;
      if (reloadedUser == null) {
        throw Exception('No se pudo validar la sesión');
      }
      if (!reloadedUser.emailVerified) {
        await _firebaseAuth.signOut();
        throw Exception(
          'Confirma tu correo antes de iniciar sesión. Revisa tu bandeja.',
        );
      }

      final docSnap = await _usersCollection.doc(reloadedUser.uid).get();

      if (!docSnap.exists) {
        final usuario = UserModel(
          id: reloadedUser.uid,
          nombre: reloadedUser.displayName ?? normalizedEmail.split('@')[0],
          email: normalizedEmail,
          fotoPerfil: reloadedUser.photoURL,
          emailVerificado: reloadedUser.emailVerified,
          proveedorAuth: 'password',
        );
        await _usersCollection.doc(reloadedUser.uid).set(usuario.toJson());
        _currentUser = usuario;
        return usuario;
      }

      final usuario = UserModel.fromJson(docSnap.data()!).copyWith(
        emailVerificado: reloadedUser.emailVerified,
        proveedorAuth: 'password',
      );
      await _usersCollection.doc(reloadedUser.uid).update({
        'emailVerificado': reloadedUser.emailVerified,
        'ultimoAcceso': FieldValue.serverTimestamp(),
      });
      _currentUser = usuario;
      return usuario;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('El usuario no existe');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email no válido');
      } else if (e.code == 'user-disabled') {
        throw Exception('La cuenta ha sido deshabilitada');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      _currentUser = null;
      if (!kIsWeb && _googleSignInInitialized) {
        await GoogleSignIn.instance.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final credential = await _googleCredential();
      _lastGoogleSignInCreatedUser =
          credential.additionalUserInfo?.isNewUser ?? false;
      final firebaseUser = credential.user;
      if (firebaseUser == null || firebaseUser.email == null) {
        throw Exception('No se pudo obtener el usuario de Google');
      }

      await _ensureValidToken(firebaseUser);
      final normalizedEmail = firebaseUser.email!.trim().toLowerCase();
      await _assertEmailAvailableForUid(normalizedEmail, firebaseUser.uid);

      final userDoc = _usersCollection.doc(firebaseUser.uid);
      final docSnap = await userDoc.get();
      _lastGoogleSignInCreatedUser =
          _lastGoogleSignInCreatedUser || !docSnap.exists;
      final user = UserModel(
        id: firebaseUser.uid,
        nombre: firebaseUser.displayName ?? normalizedEmail.split('@')[0],
        email: normalizedEmail,
        fotoPerfil: firebaseUser.photoURL,
        emailVerificado: firebaseUser.emailVerified,
        proveedorAuth: 'google.com',
      );

      if (docSnap.exists) {
        final mergedUser = UserModel.fromJson(docSnap.data()!).copyWith(
          nombre: user.nombre,
          email: user.email,
          fotoPerfil: user.fotoPerfil,
          emailVerificado: user.emailVerificado,
          proveedorAuth: user.proveedorAuth,
        );
        await userDoc.update({
          'nombre': mergedUser.nombre,
          'email': mergedUser.email,
          'fotoPerfil': mergedUser.fotoPerfil,
          'emailVerificado': mergedUser.emailVerificado,
          'proveedorAuth': mergedUser.proveedorAuth,
          'ultimoAcceso': FieldValue.serverTimestamp(),
        });
        _currentUser = mergedUser;
        return mergedUser;
      }

      await userDoc.set(user.toJson());
      _currentUser = user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential' ||
          e.code == 'email-already-in-use') {
        throw Exception('Este email ya está registrado con otro método');
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  /// Recargar datos del usuario actual desde Firestore
  Future<void> reloadCurrentUser() async {
    try {
      if (firebaseUser == null) {
        _currentUser = null;
        return;
      }

      final docSnap = await _usersCollection.doc(firebaseUser!.uid).get();

      if (docSnap.exists) {
        _currentUser = UserModel.fromJson(docSnap.data()!);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener el usuario actual desde Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      if (firebaseUser == null) {
        return null;
      }

      final docSnap = await _usersCollection.doc(firebaseUser!.uid).get();

      if (docSnap.exists) {
        return UserModel.fromJson(docSnap.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar datos del usuario en Firestore
  Future<void> updateUser(UserModel usuario) async {
    try {
      if (firebaseUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      await _usersCollection.doc(firebaseUser!.uid).update(usuario.toJson());

      _currentUser = usuario;
    } catch (e) {
      rethrow;
    }
  }

  /// Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  Future<bool> hasValidSessionToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    try {
      await _ensureValidToken(user);
      await user.reload();
      final reloadedUser = _firebaseAuth.currentUser;
      if (reloadedUser == null) return false;
      return reloadedUser.emailVerified;
    } catch (_) {
      return false;
    }
  }

  /// Verificar si el email existe
  Future<bool> emailExists(String email) async {
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureValidToken(User user) async {
    var token = await user.getIdTokenResult();
    final expiration = token.expirationTime;
    if (expiration == null || expiration.isBefore(DateTime.now())) {
      token = await user.getIdTokenResult(true);
    }
    if (token.token == null || token.token!.isEmpty) {
      throw Exception('No se pudo validar el token de sesión');
    }
  }

  Future<void> _assertEmailAvailableForUid(String email, String uid) async {
    final querySnapshot = await _usersCollection
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != uid) {
      await logout();
      throw Exception('Este email ya está registrado por otro usuario');
    }
  }

  Future<UserCredential> _googleCredential() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return _firebaseAuth.signInWithPopup(provider);
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      throw Exception('Google Sign-In no está disponible en esta plataforma');
    }

    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    }

    final googleUser = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('No se pudo obtener el token de Google');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _firebaseAuth.signInWithCredential(credential);
  }
}
