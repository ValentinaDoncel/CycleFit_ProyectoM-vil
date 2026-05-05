import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cycle_fit/models/user_model.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Obtener el usuario actual del stream de Firebase Auth
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Obtener el usuario actual de Firebase Auth
  User? get firebaseUser => _firebaseAuth.currentUser;

  /// Registrar nuevo usuario con email y contraseña
  Future<UserModel?> register({
    required String nombre,
    required String email,
    required String password,
    DateTime? fechaNacimiento,
    DateTime? ultimaPeriodo,
    String? notas,
  }) async {
    try {
      // Verificar si el email ya existe en Firestore
      final emailExistente = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (emailExistente.docs.isNotEmpty) {
        throw Exception('Este email ya está registrado');
      }

      // Crear usuario en Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
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
        email: email.trim().toLowerCase(),
        fechaNacimiento: fechaNacimiento,
        ultimaPeriodo: ultimaPeriodo,
        notas: notas,
      );

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .set(nuevoUsuario.toJson());

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
      // Autenticarse en Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // Obtener datos del usuario de Firestore
      final docSnap = await _firestore.collection('usuarios').doc(uid).get();

      if (!docSnap.exists) {
        // Si no existe el documento, crear uno con datos básicos
        final usuario = UserModel(
          id: uid,
          nombre: credential.user?.displayName ?? email.split('@')[0],
          email: email.trim().toLowerCase(),
        );
        await _firestore
            .collection('usuarios')
            .doc(uid)
            .set(usuario.toJson());
        _currentUser = usuario;
        return usuario;
      }

      final usuario = UserModel.fromJson(docSnap.data()!);
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
      await _firebaseAuth.signOut();
    } catch (e) {
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

      final docSnap = await _firestore
          .collection('usuarios')
          .doc(firebaseUser!.uid)
          .get();

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

      final docSnap = await _firestore
          .collection('usuarios')
          .doc(firebaseUser!.uid)
          .get();

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

      await _firestore
          .collection('usuarios')
          .doc(firebaseUser!.uid)
          .update(usuario.toJson());

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

  /// Verificar si el email existe
  Future<bool> emailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }
}
