import 'package:cycle_fit/controllers/notifications_controller.dart';
import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/notification_model.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationsController _controller;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.addListener(_onControllerChanged);
    _initializeController();
  }

  void _initializeController() async {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) {
      await _controller.initialize(_uid!);
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.newReminder, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(l10n.reminders, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
        ]),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildNewNotificationSection(l10n),
          const SizedBox(height: 28),
          _buildRemindersList(l10n),
        ]),
      ),
    );
  }

  Widget _buildNewNotificationSection(AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l10n.newReminder, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18))),
      SurfaceCard(
        padding: const EdgeInsets.all(4),
        child: TextField(
          controller: _controller.messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: Recuerda registrar tu ciclo',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted.withValues(alpha: 0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(icon: const Icon(Icons.clear_rounded, color: AppColors.muted, size: 20), onPressed: () => _controller.messageController.clear()),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _buildCategorySelector(l10n)), const SizedBox(width: 12), Expanded(child: _buildDateTimeSelector(l10n))]),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l10n.addReminder, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          onPressed: _controller.isLoading
              ? null
              : () async {
                  if (_uid == null) return;
                  await _controller.addNotification(_uid!);
                  if (_controller.error == null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(l10n.reminderAdded),
                      ]),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ));
                    await _controller.initialize(_uid!);
                  }
                },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      if (_controller.error != null) ...[
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.alert, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(_controller.error!, style: const TextStyle(color: AppColors.alert, fontSize: 12))),
          IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.alert, size: 16), onPressed: _controller.clearError),
        ]),
      ],
    ]);
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.categoryLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _controller.selectedCategory,
          items: NotificationModel.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: Theme.of(context).textTheme.bodyMedium))).toList(),
          onChanged: (value) {
            if (value != null) _controller.setSelectedCategory(value);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            filled: true,
            fillColor: AppColors.primarySoft.withValues(alpha: 0.15),
          ),
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
          isExpanded: true,
        ),
      ]),
    );
  }

  Widget _buildDateTimeSelector(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _selectDateTime,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.dateTimeLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (_controller.selectedDateTime != null)
              Row(children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(_formatDateTime(_controller.selectedDateTime!), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ])
            else
              Text(l10n.selectDateTime, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
          ])),
          Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 22),
        ]),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: AppColors.surface, onSurface: AppColors.text),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_controller.selectedDateTime ?? now),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: AppColors.surface, onSurface: AppColors.text),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final dateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
    _controller.setSelectedDateTime(dateTime);
  }

  String _formatDateTime(DateTime dt) {
    const months = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${dt.day} ${months[dt.month]} ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildRemindersList(AppLocalizations l10n) {
    final items = _controller.notifications;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12, top: 8), child: Text(l10n.reminders, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18))),
      if (_controller.isLoading && items.isEmpty)
        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
      else if (items.isEmpty)
        Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notifications_off_rounded, size: 56, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(l10n.noReminders, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(l10n.createReminder, style: Theme.of(context).textTheme.bodySmall),
        ])))
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final notification = items[index];
            return _ReminderCard(
              notification: notification,
              onToggle: (notif) async {
                if (_uid == null) return;
                await _controller.toggleActive(_uid!, notif);
              },
              onDelete: () async {
                if (_uid == null) return;
                await _controller.deleteNotification(_uid!, notification.id!);
              },
            );
          },
        ),
    ]);
  }
}

class _ReminderCard extends StatelessWidget {
  final NotificationModel notification;
  final ValueChanged<NotificationModel> onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({required this.notification, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(notification.categoryIcon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(notification.category, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(notification.message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(notification.formattedDateTime, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
            ]),
          ])),
          Column(children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(value: notification.active, onChanged: (_) => onToggle(notification), activeThumbColor: AppColors.primary, activeTrackColor: AppColors.primarySoft.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onDelete,
              child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.alert.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_outline_rounded, color: AppColors.alert, size: 16)),
            ),
          ]),
        ]),
      ]),
    );
  }
}