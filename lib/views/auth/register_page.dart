import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cycle_fit/controllers/register_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ChangeNotifierProvider(
            create: (_) => RegisterController(),
            child: Consumer<RegisterController>(
              builder: (context, controller, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        'Únete a CycleFit',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa tu información para comenzar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Campo Nombre
                      TextFormField(
                        controller: controller.nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo *',
                          hintText: 'Tu nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            controller.validateNombre(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Campo Email
                      TextFormField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          hintText: 'correo@ejemplo.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            controller.validateEmail(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Campo Contraseña
                      TextFormField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña *',
                          hintText: 'Mínimo 8 caracteres',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                controller.togglePasswordVisibility(),
                          ),
                          helperText:
                              'Debe incluir mayúscula, número y tener al menos 8 caracteres',
                          helperMaxLines: 2,
                        ),
                        obscureText: controller.obscurePassword,
                        validator: (value) =>
                            controller.validatePassword(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Campo Confirmar Contraseña
                      TextFormField(
                        controller: controller.confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña *',
                          hintText: 'Repite tu contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                controller.toggleConfirmPasswordVisibility(),
                          ),
                        ),
                        obscureText: controller.obscureConfirmPassword,
                        validator: (value) =>
                            controller.validateConfirmPassword(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),

                      // Sección Información Opcional
                      Text(
                        'Información Opcional',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Campo Fecha de Nacimiento
                      TextFormField(
                        controller: controller.birthDateController,
                        decoration: InputDecoration(
                          labelText: 'Fecha de Nacimiento',
                          hintText: 'dd/mm/yyyy',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range_outlined),
                            onPressed: () => _selectDate(context, controller),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) =>
                            value!.isNotEmpty
                                ? controller.validateBirthDate(value)
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Campo Última Menstruación
                      TextFormField(
                        controller: controller.lastPeriodController,
                        decoration: InputDecoration(
                          labelText: 'Última Menstruación',
                          hintText: 'dd/mm/yyyy',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range_outlined),
                            onPressed: () =>
                                _selectLastPeriodDate(context, controller),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) =>
                            value!.isNotEmpty
                                ? controller.validateLastPeriodDate(value)
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Campo Notas
                      TextFormField(
                        controller: controller.notesController,
                        decoration: InputDecoration(
                          labelText: 'Notas Adicionales',
                          hintText: 'Información adicional (opcional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.notes_outlined),
                        ),
                        maxLines: 3,
                        maxLength: 500,
                        validator: (value) =>
                            controller.validateOptionalNotes(value),
                      ),
                      const SizedBox(height: 12),

                      // Mensaje de error
                      if (controller.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                                onPressed: () => controller.clearError(),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Botón Registrarse
                      ElevatedButton(
                        onPressed: controller.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await controller.register();
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '¡Bienvenido a CycleFit!',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    if (mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/dashboard',
                                        (route) => false,
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Crear Cuenta',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Enlace Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Inicia Sesión',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, RegisterController controller) async {
    final now = DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      controller.setSelectedBirthDate(selectedDate);
    }
  }

  Future<void> _selectLastPeriodDate(
      BuildContext context, RegisterController controller) async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 120));
    final lastDate = now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      controller.lastPeriodController.text =
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    }
  }
}
