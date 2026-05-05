import 'package:flutter/material.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';

/// AuthGuard protege rutas requiriendo autenticación.
/// Si el usuario no está autenticado, lo redirige al login.
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    // Si el usuario está autenticado, mostrar la pantalla
    if (auth.isLoggedIn) {
      return child;
    }

    // Si no está autenticado, redirigir al login
    Future.microtask(() {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
