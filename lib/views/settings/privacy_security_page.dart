import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final horizontal = context.pageHorizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary), onPressed: () => Navigator.pop(context)),
        title: Text(l10n.privacyTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Cuenta ──
          _buildSectionTitle(l10n.accountSection),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              _buildMenuTile(Icons.lock_outlined, l10n.changePassword, l10n.changePasswordSub, () => _showChangePasswordDialog(context, l10n)),
              const Divider(height: 1, indent: 60),
              _buildMenuTile(Icons.email_outlined, l10n.changeEmail, l10n.changeEmailSub, () => _showChangeEmailSheet(context, l10n)),
              const Divider(height: 1, indent: 60),
              _buildMenuTile(Icons.verified_user_outlined, l10n.twoFactorAuth, l10n.twoFactorSub, () {}),
              const Divider(height: 1, indent: 60),
              _buildMenuTile(Icons.fingerprint_outlined, l10n.biometricAuth, l10n.biometricSub, () {}),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Privacidad ──
          _buildSectionTitle(l10n.privacySection),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              _buildMenuTile(Icons.person_off_outlined, l10n.privateProfile, l10n.privateProfileSub, () {}),
              const Divider(height: 1, indent: 60),
              _buildMenuTile(Icons.insert_chart_outlined, l10n.analyticsData, l10n.analyticsSub, () {}),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Datos ──
          _buildSectionTitle(l10n.dataSection),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              _buildMenuTile(Icons.download_outlined, l10n.exportData, l10n.exportDataSub, () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.featureInProgress), duration: const Duration(seconds: 2)));
              }),
              const Divider(height: 1, indent: 60),
              _buildMenuTile(Icons.upload_outlined, l10n.importData, l10n.importDataSub, () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.featureInProgress), duration: const Duration(seconds: 2)));
              }),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Eliminar cuenta ──
          SurfaceCard(
            color: AppColors.alert.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: _buildMenuTile(Icons.delete_forever_outlined, l10n.deleteAccount, l10n.deleteAccountSub, () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.featureInProgress), duration: const Duration(seconds: 2)));
            }),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12, top: 4), child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)));
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
        ]),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changePasswordTitle),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l10n.passwordInstructions),
                  const SizedBox(height: 16),
                  TextField(controller: currentPasswordController, decoration: InputDecoration(labelText: l10n.currentPassword, prefixIcon: const Icon(Icons.lock_outlined)), obscureText: true),
                  const SizedBox(height: 12),
                  TextField(controller: newPasswordController, decoration: InputDecoration(labelText: l10n.newPassword, prefixIcon: const Icon(Icons.lock_outlined)), obscureText: true),
                  const SizedBox(height: 12),
                  TextField(controller: confirmPasswordController, decoration: InputDecoration(labelText: l10n.confirmPassword, prefixIcon: const Icon(Icons.lock_outlined)), obscureText: true),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
                FilledButton(
                  onPressed: () async {
                    if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.allFieldsRequired), backgroundColor: AppColors.alert));
                      return;
                    }
                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordMinLength), backgroundColor: AppColors.alert));
                      return;
                    }
                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordsDontMatch), backgroundColor: AppColors.alert));
                      return;
                    }
                    try {
Navigator.pop(dialogContext);
                       if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Row(children: [Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Text(l10n.changePasswordTitle)]), backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.alert));
                    }
                  },
                  child: Text(l10n.updatePassword),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangeEmailSheet(BuildContext context, AppLocalizations l10n) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.changeEmailTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(l10n.changeEmailSubtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9D8E8F))),
                const SizedBox(height: 16),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Nuevo correo electrónico', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña actual', prefixIcon: Icon(Icons.lock_outlined), border: OutlineInputBorder()), obscureText: true),
                if (error != null) ...[SizedBox(height: 8), Text(error!, style: const TextStyle(color: Color(0xFFFF2E4D), fontSize: 12))],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final newEmail = emailController.text.trim();
                      final password = passwordController.text.trim();
                      if (newEmail.isEmpty || password.isEmpty) {
                        setSheetState(() => error = l10n.allFieldsRequired);
                        return;
                      }
                      setSheetState(() {
                        error = null;
                      });
                      try {
                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Expanded(child: Text(l10n.emailUpdated))]),
                                SizedBox(height: 4),
                                Text(l10n.clickVerificationLink, style: TextStyle(fontSize: 11)),
                              ]),
                              backgroundColor: const Color(0xFF61D882),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      } catch (e) {
                        setSheetState(() => error = e.toString());
                      }
                    },
                    child: Text(l10n.updateEmail),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(sheetContext), child: Text(l10n.cancel)),
              ]),
            );
          },
        );
      },
    );
  }
}