import 'package:cycle_fit/controllers/notifications_controller.dart';
import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  late NotificationsController _controller;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.addListener(_onChanged);
    _initializeController();
  }

  void _initializeController() async {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) {
      await _controller.initialize(_uid!);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final horizontal = context.pageHorizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notificationSettings,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Canal de notificaciones ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                l10n.notificationChannels,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
            ),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _buildToggle(
                    icon: Icons.notifications_active_rounded,
                    title: l10n.pushNotifications,
                    subtitle: l10n.pushNotificationsSub,
                    value: _controller.pushNotifications,
                    onChanged: (_) => _controller.togglePushNotifications(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildToggle(
                    icon: Icons.email_outlined,
                    title: l10n.emailNotifications,
                    subtitle: l10n.emailNotificationsSub,
                    value: _controller.emailNotifications,
                    onChanged: (_) => _controller.toggleEmailNotifications(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildToggle(
                    icon: Icons.sms_rounded,
                    title: l10n.smsNotifications,
                    subtitle: l10n.smsNotificationsSub,
                    value: _controller.smsNotifications,
                    onChanged: (_) => _controller.toggleSmsNotifications(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Recordatorios ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.reminders,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
            ),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _buildToggle(
                    icon: Icons.calendar_today_rounded,
                    title: l10n.cycleReminder,
                    subtitle: l10n.cycleReminderSub,
                    value: _controller.reminderCycle,
                    onChanged: (_) => _controller.toggleReminderCycle(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildToggle(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.symptomReminder,
                    subtitle: l10n.symptomReminderSub,
                    value: _controller.reminderSymptoms,
                    onChanged: (_) => _controller.toggleReminderSymptoms(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildToggle(
                    icon: Icons.fitness_center_rounded,
                    title: l10n.workoutReminder,
                    subtitle: l10n.workoutReminderSub,
                    value: _controller.reminderWorkout,
                    onChanged: (_) => _controller.toggleReminderWorkout(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildToggle(
                    icon: Icons.summarize_rounded,
                    title: l10n.weeklySummary,
                    subtitle: l10n.weeklySummarySub,
                    value: _controller.weeklySummary,
                    onChanged: (_) => _controller.toggleWeeklySummary(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _controller.isLoading
                    ? null
                    : () async {
if (_uid == null) return;
                         await _controller.saveSettings(_uid!);
                         final error = _controller.error;
                         if (!mounted) return;
                         if (error != null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(error), backgroundColor: AppColors.alert),
                           );
                         } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Row(
                                 children: const [
                                   Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                   SizedBox(width: 10),
                                   Text('Configuración guardada'),
                                 ],
                               ),
                               backgroundColor: AppColors.success,
                               behavior: SnackBarBehavior.floating,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                               duration: const Duration(seconds: 2),
                             ),
                           );
                         }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _controller.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.saveSettings, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            if (_controller.error != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.alert, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_controller.error!, style: const TextStyle(color: AppColors.alert, fontSize: 12))),
                  IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.alert, size: 16), onPressed: _controller.clearError),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ])),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary, activeTrackColor: AppColors.primarySoft.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}