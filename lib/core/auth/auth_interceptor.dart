import 'package:flutter/material.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';

/// Interceptor de autenticación que verifica si el usuario está autenticado
/// antes de acceder a una ruta protegida
class AuthInterceptor {
  static Future<bool> checkAuthentication() async {
    final authService = AuthService();
    
    // Recargar datos del usuario actual
    await authService.reloadCurrentUser();
    
    return authService.isLoggedIn;
  }

  /// Obtener usuario actual o redirigir al login
  static Future<bool> requireAuthentication(BuildContext context) async {
    final isAuthenticated = await checkAuthentication();
    
    if (!isAuthenticated && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return false;
    }
    
    return true;
  }

  /// Verificar autenticación antes de abrir una ruta
  static Future<void> verifyAndNavigate(
    BuildContext context,
    String routeName,
  ) async {
    final isAuthenticated = await checkAuthentication();
    
    if (isAuthenticated && context.mounted) {
      Navigator.pushNamed(context, routeName);
    } else if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }
}

/// Wrapper para rutas que requieren autenticación
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final String routeName;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Si hay error o sin conexión
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay usuario autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return child;
        }

        // Si no hay usuario, redirigir a login
        Future.microtask(() {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
