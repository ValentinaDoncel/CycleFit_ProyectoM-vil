import 'package:cycle_fit/core/l10n/app_localizations.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

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
        title: Text(l10n.helpTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Preguntas frecuentes ──
            Padding(padding: const EdgeInsets.only(bottom: 16, top: 8), child: Text(l10n.faqTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16))),
            SurfaceCard(padding: EdgeInsets.zero, margin: const EdgeInsets.only(bottom: 24), child: Column(children: [
              _FAQTile(question: '¿Cómo funciona el seguimiento del ciclo?', answer: 'La app registra tu ciclo menstrual y te muestra en qué fase te encuentras. Solo necesitas registrar el inicio de tu período y la duración promedio de tu ciclo.'),
              const Divider(height: 1),
              _FAQTile(question: '¿Mis datos están seguros?', answer: 'Sí, tus datos se almacenan de forma segura en Firebase con cifrado. Solo tú puedes acceder a tu información.'),
              const Divider(height: 1),
              _FAQTile(question: '¿Puedo usarla sin conexión?', answer: 'Sí, los datos se sincronizan automáticamente cuando recuperas la conexión a internet.'),
              const Divider(height: 1),
              _FAQTile(question: '¿Cómo registro síntomas?', answer: 'Ve a la sección de Síntomas y selecciona los que estés experimentando hoy. Puedes agregar notas adicionales.'),
              const Divider(height: 1),
              _FAQTile(question: '¿Cómo cambio mi objetivo?', answer: 'Ve a Perfil > Información personal y edita tu objetivo principal.'),
            ])),

            // ── Contacto ──
            Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(l10n.contactTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16))),
            SurfaceCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
              _ContactTile(icon: Icons.email_outlined, title: l10n.supportEmail, detail: '', onTap: () => debugPrint('Abrir correo de soporte')),
              const Divider(height: 1, indent: 60),
              _ContactTile(icon: Icons.chat_bubble_outline_rounded, title: l10n.liveChat, detail: l10n.liveChatHours, onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función en desarrollo. Pronto disponible.'), duration: Duration(seconds: 2))); }),
              const Divider(height: 1, indent: 60),
              _ContactTile(icon: Icons.help_outline_rounded, title: l10n.helpCenter, detail: l10n.helpCenterSub, onTap: () => debugPrint('Abrir centro de ayuda web')),
            ])),
            const SizedBox(height: 24),

            // ── Reportar problema ──
            SurfaceCard(padding: const EdgeInsets.all(20), child: Column(children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.alert.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.bug_report_outlined, color: AppColors.alert, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.reportProblem, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(l10n.reportProblemSub, style: Theme.of(context).textTheme.bodySmall),
                ])),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 44, child: OutlinedButton.icon(icon: const Icon(Icons.report_problem_rounded, size: 18), label: Text(l10n.sendReport), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función en desarrollo.'), duration: Duration(seconds: 2))), style: OutlinedButton.styleFrom(foregroundColor: AppColors.alert, side: const BorderSide(color: AppColors.alert), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ])),
          ],
        ),
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(title: Text(question, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)), childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16), children: [Text(answer, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5))]);
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onTap;
  const _ContactTile({required this.icon, required this.title, required this.detail, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (detail.isNotEmpty) const SizedBox(height: 2),
        if (detail.isNotEmpty) Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
      ])),
      const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
    ])));
  }
}