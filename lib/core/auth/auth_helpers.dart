import 'package:flutter/material.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';

/// Extensión para facilitarlogout desde cualquier contexto
extension AuthLogout on BuildContext {
  /// Realiza logout y redirige al login
  Future<void> logout() async {
    final authService = AuthService();
    
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await authService.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          this,
          '/login',
          (route) => false,
        );
      }
    }
  }

  /// Verifica si el usuario está autenticado
  bool get isAuthenticated => AuthService().isLoggedIn;

  /// Obtiene el usuario actual
  get currentUser => AuthService().currentUser;
}

/// Utilidades para mostrar diálogos de autenticación
class AuthDialogs {
  static Future<void> showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  static Future<void> showSessionExpired(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesión Expirada'),
        content: const Text('Tu sesión ha expirado. Por favor inicia sesión de nuevo.'),
        actions: [
          TextButton(
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  static Future<void> showAuthError(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
