import 'package:cycle_fit/controllers/register_controller.dart';
import 'package:cycle_fit/widgets/onboarding_choice_tile.dart';
import 'package:cycle_fit/widgets/onboarding_step_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _accountFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Consumer<RegisterController>(
        builder: (context, controller, _) {
          return OnboardingStepLayout(
            progress: controller.progress,
            title: _titleForStep(controller.currentStep),
            primaryLabel: _primaryLabelForStep(controller.currentStep),
            isLoading: controller.isLoading,
            errorMessage: controller.errorMessage,
            onClearError: controller.clearError,
            onBackPressed: () => _handleBack(context, controller),
            onSkipPressed: controller.canSkipCurrentStep
                ? () async => _handleSkip(context, controller)
                : null,
            onPrimaryPressed: () async =>
                _handleContinue(context, controller),
            child: _bodyForStep(context, controller),
          );
        },
      ),
    );
  }

  Widget _bodyForStep(BuildContext context, RegisterController controller) {
    switch (controller.currentStep) {
      case RegisterStep.account:
        return _AccountStep(
          formKey: _accountFormKey,
          controller: controller,
          onBirthDateTap: () => _selectBirthDate(context, controller),
          onLastPeriodTap: () => _selectLastPeriodDate(context, controller),
        );
      case RegisterStep.regularity:
        return OnboardingChoiceList(
          children: controller.regularityOptions
              .map(
                (item) => OnboardingChoiceTile(
                  label: item.label,
                  isSelected: item.isSelected,
                  onTap: () => controller.selectRegularity(item.keyName),
                ),
              )
              .toList(),
        );
      case RegisterStep.symptoms:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OnboardingChoiceList(
              children: controller.symptomChoices
                  .map(
                    (item) => OnboardingChoiceTile(
                      label: item.label,
                      isSelected: item.isSelected,
                      onTap: () => controller.toggleSymptom(item.keyName),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            const Text(
              '¿Cómo te sientes hoy?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            OnboardingChoiceList(
              children: controller.energyOptions
                  .map(
                    (item) => OnboardingChoiceTile(
                      label: item.label,
                      isSelected: item.isSelected,
                      onTap: () => controller.selectEnergy(item.keyName),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      case RegisterStep.workout:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OnboardingChoiceList(
              children: controller.workoutCategories
                  .map(
                    (item) => OnboardingChoiceTile(
                      label: item.label,
                      isSelected: item.isSelected,
                      onTap: () =>
                          controller.selectWorkoutCategory(item.keyName),
                    ),
                  )
                  .toList(),
            ),
            if (controller.visibleWorkoutChoices.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text(
                'Elige una opción',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              OnboardingChoiceList(
                children: controller.visibleWorkoutChoices
                    .map(
                      (item) => OnboardingChoiceTile(
                        label: item.label,
                        subtitle:
                            '${item.durationMinutes} min • ${item.calories} kcal aprox.',
                        isSelected: item.isSelected,
                        onTap: () =>
                            controller.selectWorkoutDetail(item.keyName),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              const Text(
                'Intensidad',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _IntensityOptions(controller: controller),
            ],
          ],
        );
    }
  }

  String _titleForStep(RegisterStep step) {
    switch (step) {
      case RegisterStep.account:
        return 'Crea tu cuenta';
      case RegisterStep.regularity:
        return '¿Es tu periodo regular?';
      case RegisterStep.symptoms:
        return '¿Cuál de estos síntomas has experimentado?';
      case RegisterStep.workout:
        return '¿Qué tipo de entrenamiento realizas?';
    }
  }

  String _primaryLabelForStep(RegisterStep step) {
    switch (step) {
      case RegisterStep.workout:
        return 'Finalizar';
      default:
        return 'Siguiente';
    }
  }

  Future<void> _handleContinue(
    BuildContext context,
    RegisterController controller,
  ) async {
    if (controller.currentStep == RegisterStep.account &&
        !_accountFormKey.currentState!.validate()) {
      return;
    }

    final success = await controller.continueFromCurrentStep();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bienvenida a CycleFit')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
    }
  }

  Future<void> _handleSkip(
    BuildContext context,
    RegisterController controller,
  ) async {
    final wasWorkoutStep = controller.currentStep == RegisterStep.workout;
    controller.skipCurrentStep();
    if (!wasWorkoutStep) return;

    final success = await controller.register();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bienvenida a CycleFit')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
    }
  }

  void _handleBack(BuildContext context, RegisterController controller) {
    if (controller.isFirstStep) {
      Navigator.pop(context);
      return;
    }
    controller.previousStep();
  }

  Future<void> _selectBirthDate(
    BuildContext context,
    RegisterController controller,
  ) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedBirthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate != null) {
      controller.setSelectedBirthDate(selectedDate);
    }
  }

  Future<void> _selectLastPeriodDate(
    BuildContext context,
    RegisterController controller,
  ) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedLastPeriodDate ?? now,
      firstDate: now.subtract(const Duration(days: 120)),
      lastDate: now,
    );

    if (selectedDate != null) {
      controller.setSelectedLastPeriodDate(selectedDate);
    }
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({
    required this.formKey,
    required this.controller,
    required this.onBirthDateTap,
    required this.onLastPeriodTap,
  });

  final GlobalKey<FormState> formKey;
  final RegisterController controller;
  final VoidCallback onBirthDateTap;
  final VoidCallback onLastPeriodTap;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _TextInput(
            controller: controller.nombreController,
            label: 'Nombre completo',
            validator: controller.validateNombre,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _TextInput(
            controller: controller.emailController,
            label: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _TextInput(
            controller: controller.passwordController,
            label: 'Contraseña',
            obscureText: controller.obscurePassword,
            validator: controller.validatePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 14),
          _TextInput(
            controller: controller.confirmPasswordController,
            label: 'Confirmar contraseña',
            obscureText: controller.obscureConfirmPassword,
            validator: controller.validateConfirmPassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
          const SizedBox(height: 14),
          _TextInput(
            controller: controller.birthDateController,
            label: 'Fecha de nacimiento',
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona tu fecha de nacimiento';
              }
              return controller.validateBirthDate(value);
            },
            onTap: onBirthDateTap,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: onBirthDateTap,
            ),
          ),
          const SizedBox(height: 14),
          _TextInput(
            controller: controller.lastPeriodController,
            label: 'Última menstruación',
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona tu última menstruación';
              }
              return controller.validateLastPeriodDate(value);
            },
            onTap: onLastPeriodTap,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: onLastPeriodTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF668B), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _IntensityOptions extends StatelessWidget {
  const _IntensityOptions({required this.controller});

  final RegisterController controller;

  @override
  Widget build(BuildContext context) {
    return OnboardingChoiceList(
      children: controller.intensityChoices
          .map(
            (intensity) => OnboardingChoiceTile(
              label: intensity,
              isSelected: controller.selectedWorkoutIntensity == intensity,
              onTap: () => controller.selectWorkoutIntensity(intensity),
            ),
          )
          .toList(),
    );
  }
}
