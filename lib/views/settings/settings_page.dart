import 'package:cycle_fit/controllers/settings_controller.dart';
import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController _controller;
  bool _listenerAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<SettingsController>();
    if (!_listenerAttached) {
      _controller.addListener(_onChanged);
      _listenerAttached = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final horizontal = context.pageHorizontalPadding;
    final darkModeLabel = _controller.darkMode ? l10n.darkModeOn : l10n.darkModeOff;

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
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ──
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 8),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.settingsTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                      const SizedBox(height: 2),
                      Text('${l10n.appearance} / ${l10n.language} / ${l10n.units}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tema ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.appearance, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            ),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.brightness_4_rounded,
                    title: l10n.darkMode,
                    subtitle: darkModeLabel,
                    trailing: Switch(
                      value: _controller.darkMode,
                      onChanged: (_) {
                        _controller.toggleDarkMode();
                        _updateTheme(context);
                      },
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primarySoft.withValues(alpha: 0.5),
                    ),
                    onTap: () {
                      _controller.toggleDarkMode();
                      _updateTheme(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Idioma ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.language, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            ),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    title: l10n.appLanguage,
                    subtitle: _controller.language,
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
                    onTap: () => _showLanguageDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Unidades ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.units, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            ),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.monitor_weight_outlined,
                    title: l10n.measurementSystem,
                    subtitle: _controller.units,
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
                    onTap: () => _showUnitsDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Acerca de ──
            Center(
              child: Text(l10n.version, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTheme(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_controller.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(_controller.darkMode ? l10n.darkThemeActivated : l10n.lightThemeActivated),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<SettingsController>();
    final selectedLang = controller.language;
    final languages = [l10n.spanish, l10n.english, l10n.portuguese];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.selectLanguage),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: languages.map((lang) {
                  return RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: selectedLang,
                    onChanged: (value) {
                      setDialogState(() {
                        controller.setLanguage(value!);
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.languageChanged} ${controller.language}'), duration: const Duration(seconds: 2)),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUnitsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _controller.units;
    final units = [l10n.metric, l10n.imperial];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.selectUnits),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: units.map((unit) {
                  return RadioListTile<String>(
                    title: Text(unit),
                    value: unit,
                    groupValue: selected,
                    onChanged: (value) {
                      setDialogState(() {
                        _controller.setUnits(value!);
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.unitsUpdated), duration: const Duration(seconds: 2)),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}