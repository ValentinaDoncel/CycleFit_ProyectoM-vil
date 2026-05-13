import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        title: Text(l10n.aboutTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 28),
        child: Column(children: [
          Container(width: 90, height: 90, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 44)),
          const SizedBox(height: 16),
          Text('CycleFit', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(l10n.aboutDescription, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w500, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Align(alignment: Alignment.centerLeft, child: Text(l10n.featuresTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16))),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.calendar_month_rounded, title: l10n.cycleTracking, description: l10n.cycleTrackingSub),
          const SizedBox(height: 8),
          _FeatureRow(icon: Icons.favorite_border_rounded, title: l10n.symptomTracking, description: l10n.symptomTrackingSub),
          const SizedBox(height: 8),
          _FeatureRow(icon: Icons.fitness_center_rounded, title: l10n.exerciseRecommendations, description: l10n.exerciseRecommendationsSub),
          const SizedBox(height: 8),
          _FeatureRow(icon: Icons.auto_awesome_rounded, title: l10n.aiTips, description: l10n.aiTipsSub),
          const SizedBox(height: 8),
          _FeatureRow(icon: Icons.people_outline_rounded, title: l10n.community, description: l10n.communitySub),
          const SizedBox(height: 8),
          _FeatureRow(icon: Icons.tips_and_updates_rounded, title: l10n.dailyTips, description: l10n.dailyTipsSub),
          const SizedBox(height: 32),
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(children: [
            Text(l10n.license, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(l10n.copyright, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ])),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureRow({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ])),
    ]);
  }
}