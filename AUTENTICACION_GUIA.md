# Sistema de Autenticación con Firebase

## Descripción General

Se ha implementado un sistema completo de autenticación y validación de acceso usando Firebase Authentication y Firestore. El sistema protege las rutas para que solo usuarios autenticados puedan acceder a la aplicación.

## Archivos Creados

### Modelos
- **`lib/models/user_model.dart`** - Modelo de usuario con integración a Firebase

### Servicios de Autenticación
- **`lib/core/services/auth/auth_service.dart`** - Servicio centralizado que maneja:
  - Registro de usuarios con Firebase Auth
  - Login con validación contra Firebase
  - Logout
  - Recuperación de contraseña
  - Sincronización con Firestore

### Controladores
- **`lib/controllers/login_controller.dart`** - Controlador para la pantalla de login
  - Validación de email y contraseña
  - Manejo de estados de carga y errores
  - Visibilidad de contraseña

- **`lib/controllers/register_controller.dart`** - Controlador para la pantalla de registro
  - Validación completa del formulario
  - Soporte para datos opcionales (fecha de nacimiento, última menstruación)
  - Manejo de errores

### Validadores
- **`lib/core/validators/register_validators.dart`** - Validadores reutilizables:
  - Email (formato válido)
  - Contraseña (mínimo 8 caracteres, mayúscula y número)
  - Nombres (letras y espacios)
  - Fechas (nacimiento, menstruación)
  - Edad (coherencia con fecha de nacimiento)

### Protección de Rutas
- **`lib/core/auth/auth_guard.dart`** - Guard que protege rutas:
  - Verifica si el usuario está autenticado
  - Redirige al login si no está autenticado

### Pantallas de Autenticación
- **`lib/views/auth/login_page.dart`** - Pantalla de login
  - Interfaz intuitiva con campos de email y contraseña
  - Validaciones en tiempo real
  - Link para crear nueva cuenta
  - Link para recuperar contraseña

- **`lib/views/auth/register_page.dart`** - Pantalla de registro
  - Campos obligatorios: nombre, email, contraseña
  - Campos opcionales: fecha nacimiento, última menstruación, notas
  - Validaciones completas
  - Date picker para fechas

## Flujo de Autenticación

```
1. Usuario inicia la app
   ↓
2. StreamBuilder en main.dart verifica si hay usuario autenticado
   ↓
3. Si NO hay usuario → Mostrar LoginPage
   ↓
4. Usuario puede:
   a) Iniciar sesión con email y contraseña
   b) Crear nueva cuenta (RegisterPage)
   ↓
5. Al registrarse o iniciar sesión correctamente:
   - Se autentica en Firebase Auth
   - Se guarda/obtiene datos de usuario de Firestore
   - Se redirige al DashboardPage
   ↓
6. Si el usuario cierra sesión:
   - Se ejecuta logout en Firebase Auth
   - Se redirige al LoginPage
   ↓
7. Si trata de acceder a ruta protegida sin autenticación:
   - AuthGuard lo redirige al LoginPage
```

## Cambios en Archivos Existentes

### `lib/main.dart`
- Agregado MultiProvider para Provider
- Agregado StreamBuilder que verifica autenticación
- Configuradas rutas nombradas para login, register y dashboard
- Redirección automática según estado de autenticación

### `pubspec.yaml`
- Agregada dependencia: `provider: ^6.0.0`

## Cómo Usar el Sistema

### 1. Login
```dart
final controller = LoginController();
final success = await controller.login();
// Si success == true, el usuario está autenticado
// Redirigir a dashboard
```

### 2. Register
```dart
final controller = RegisterController();
final success = await controller.register();
// Si success == true, crear usuario y guardar en Firestore
// Redirigir a dashboard
```

### 3. Obtener Usuario Actual
```dart
final authService = AuthService();
final usuario = authService.currentUser;
// O escuchar cambios de autenticación:
authService.authStateChanges.listen((user) {
  // El usuario cambió
});
```

### 4. Logout
```dart
final authService = AuthService();
await authService.logout();
// El usuario será redirigido al login automáticamente
```

### 5. Proteger Rutas
```dart
// Opción 1: Con AuthGuard
AuthGuard(
  child: MiPantalla(),
)

// Opción 2: Con rutas nombradas en MaterialApp
'/dashboard': (context) => AuthGuard(child: DashboardPage(...)),
```

## Validaciones

### Contraseña
- Mínimo 8 caracteres
- Debe incluir al menos una mayúscula
- Debe incluir al menos un número
- Opcional: puede incluir caracteres especiales

### Email
- Formato válido (usuario@dominio.com)

### Nombre
- No puede estar vacío
- Mínimo 2 caracteres, máximo 50
- Solo letras y espacios
- Sin números

### Fecha de Nacimiento
- Formato: dd/mm/yyyy
- No puede ser futura
- La edad calculada debe coincidir (con tolerancia de 1 año)

### Última Menstruación
- Formato: dd/mm/yyyy
- No puede ser futura
- No puede ser hace más de 120 días

## Estructura de Datos en Firestore

Colección: `usuarios`
Documento ID: UID del usuario (autogenerado por Firebase Auth)

```json
{
  "id": "uid_del_usuario",
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "fotoPerfil": null,
  "fechaNacimiento": "Timestamp",
  "ultimaPeriodo": "Timestamp",
  "notas": "Texto opcional",
  "fechaRegistro": "Timestamp"
}
```

## Próximos Pasos Recomendados

1. **Agregar Logout a la UI**
   - Agregar botón de logout en AppShell o menú de perfil
   - Crear página de perfil con opción de logout

2. **Recuperación de Contraseña**
   - Implementar pantalla de recuperación
   - Usar `authService.sendPasswordResetEmail(email)`

3. **Edición de Perfil**
   - Crear pantalla para editar información del usuario
   - Usar `authService.updateUser(usuario)`

4. **Autenticación Social**
   - Agregar login con Google
   - Agregar login con Apple

5. **Verificación de Email**
   - Implementar verificación de email al registrarse
   - Enviar email de confirmación

## Notas Importantes

- ✅ El sistema está completamente integrado con Firebase
- ✅ Las contraseñas se almacenan de forma segura en Firebase Auth
- ✅ Los datos adicionales se guardan en Firestore
- ✅ El usuario no autenticado SIEMPRE será redirigido al login
- ✅ Las rutas están protegidas automáticamente
- ⚠️ Asegurar que las reglas de Firestore estén configuradas correctamente
- ⚠️ Verificar que Firebase esté inicializado antes de usar el sistema

## Archivos de Ejemplo en CAMBIOS

Los archivos en `CAMBIOS/` servían como referencia para implementar esta solución. Ya fueron adaptados e integrados en el proyecto principal, por lo que esa carpeta puede ser eliminada.
