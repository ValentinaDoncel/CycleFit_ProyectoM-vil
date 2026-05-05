import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingStepLayout extends StatelessWidget {
  const OnboardingStepLayout({
    super.key,
    required this.progress,
    required this.title,
    required this.child,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.onBackPressed,
    this.onSkipPressed,
    this.isLoading = false,
    this.errorMessage,
    this.onClearError,
  });

  final double progress;
  final String title;
  final Widget child;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSkipPressed;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onClearError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 10, 26, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: onBackPressed,
                    color: Colors.black,
                  ),
                  const Expanded(
                    child: Text(
                      'CycleFit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSkipPressed,
                    child: Text(
                      onSkipPressed == null ? '' : 'Saltar',
                      style: const TextStyle(
                        color: Color(0xFF4A4145),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE8E8E8),
                  color: const Color(0xFFFF668B),
                ),
              ),
              const SizedBox(height: 46),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 29,
                  height: 1.32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      child,
                      if (errorMessage != null) ...[
                        const SizedBox(height: 18),
                        _ErrorMessage(
                          message: errorMessage!,
                          onClose: onClearError,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 64,
                child: FilledButton(
                  onPressed: isLoading ? null : onPrimaryPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA0B9),
                    disabledBackgroundColor: const Color(0xFFF3D3DD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          primaryLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
    this.onClose,
  });

  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, color: Colors.red.shade600),
            ),
        ],
      ),
    );
  }
}
