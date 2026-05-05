# Ejemplo: Agregar Logout a una Página

## Opción 1: Botón de Logout en un AppBar

```dart
import 'package:flutter/material.dart';
import 'package:cycle_fit/core/auth/auth_helpers.dart';

class MiPagina extends StatelessWidget {
  const MiPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Página'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.logout(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Contenido de la página'),
      ),
    );
  }
}
```

## Opción 2: Botón de Logout en un Menú

```dart
import 'package:flutter/material.dart';
import 'package:cycle_fit/core/auth/auth_dialogs.dart';

class MiPagina extends StatelessWidget {
  const MiPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Página'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Cerrar Sesión'),
                onTap: () => AuthDialogs.showLogoutConfirmation(context),
              ),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Text('Contenido de la página'),
      ),
    );
  }
}
```

## Opción 3: Página de Perfil Completa

```dart
import 'package:flutter/material.dart';
import 'package:cycle_fit/core/services/auth/auth_service.dart';
import 'package:cycle_fit/core/auth/auth_helpers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              child: Text(user?.nombre[0] ?? '?'),
            ),
            const SizedBox(height: 16),
            // Información del usuario
            Text(
              user?.nombre ?? 'Usuario',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'Sin email',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            // Botón de logout
            ElevatedButton.icon(
              onPressed: () => context.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Opción 4: Usar AuthInterceptor para Verificación

```dart
import 'package:flutter/material.dart';
import 'package:cycle_fit/core/auth/auth_interceptor.dart';

class MiPagina extends StatelessWidget {
  const MiPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthInterceptor.checkAuthentication(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data == true) {
            return const Center(child: Text('Usuario autenticado'));
          }

          return const Center(child: Text('No autenticado'));
        },
      ),
    );
  }
}
```

## Opción 5: Usar ProtectedRoute

```dart
final routes = {
  '/dashboard': (context) => const ProtectedRoute(
    routeName: '/dashboard',
    child: DashboardPage(),
  ),
  '/profile': (context) => const ProtectedRoute(
    routeName: '/profile',
    child: ProfilePage(),
  ),
};
```

## Verificar Usuario Actual en Cualquier Lugar

```dart
import 'package:cycle_fit/core/services/auth/auth_service.dart';

final authService = AuthService();

// Obtener usuario actual
if (authService.isLoggedIn) {
  final usuario = authService.currentUser;
  print('Usuario: ${usuario?.nombre}');
}

// Escuchar cambios de autenticación
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('Usuario autenticado: ${user.uid}');
  } else {
    print('Sin usuario');
  }
});

// Recargar datos del usuario
await authService.reloadCurrentUser();
```

## Manejar Errores de Autenticación

```dart
import 'package:cycle_fit/core/auth/auth_dialogs.dart';

try {
  await authService.logout();
} catch (e) {
  if (context.mounted) {
    AuthDialogs.showAuthError(
      context,
      'Error al cerrar sesión: $e',
    );
  }
}
```

## Navegar Seguro (Verificando Autenticación)

```dart
import 'package:cycle_fit/core/auth/auth_interceptor.dart';

// Navegar solo si el usuario está autenticado
AuthInterceptor.verifyAndNavigate(context, '/dashboard');
```
