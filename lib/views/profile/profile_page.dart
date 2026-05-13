import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Text(
              'Perfil',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Column(
                children: [
                  SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(controller.profileAvatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0x55000000),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.profileName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.profileEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Información personal',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 16),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditProfileDialog(context),
                              child: Text(
                                'Editar',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: [
                            for (final item in controller.profileInfo)
                              _ProfileInfoTile(item: item),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      for (
                        var i = 0;
                        i < controller.profileStats.length;
                        i++
                      ) ...[
                        Expanded(
                          child: SurfaceCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 14,
                            ),
                            child: _ProfileStatCard(
                              item: controller.profileStats[i],
                            ),
                          ),
                        ),
                        if (i < controller.profileStats.length - 1)
                          const SizedBox(width: 10),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (
                          var i = 0;
                          i < controller.profileMenu.length;
                          i++
                        ) ...[
                          _ProfileMenuRow(item: controller.profileMenu[i]),
                          if (i < controller.profileMenu.length - 1)
                            const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await controller.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (_) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF2E4D),
                        side: const BorderSide(color: Color(0xFFFF2E4D)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Cyclofit v1.0.0 • Hecho con 💗',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final nameController = TextEditingController(text: controller.profileName);
    final emailController = TextEditingController(
      text: controller.profileEmail,
    );
    final ageController = TextEditingController(
      text: controller.profileInfo
          .firstWhere((item) => item.label == 'Edad')
          .value
          .replaceAll(' años', ''),
    );
    final weightController = TextEditingController(
      text: controller.profileInfo
          .firstWhere((item) => item.label == 'Peso')
          .value
          .replaceAll(' kg', ''),
    );
    final heightController = TextEditingController(
      text: controller.profileInfo
          .firstWhere((item) => item.label == 'Estatura')
          .value
          .replaceAll(' cm', ''),
    );
    final goalController = TextEditingController(
      text: controller.profileInfo
          .firstWhere((item) => item.label == 'Objetivo principal')
          .value,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Peso'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Estatura'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: 'Objetivo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: controller.isSavingProfile
                  ? null
                  : () async {
                      await controller.saveProfile(
                        UserProfileData(
                          name: nameController.text,
                          email: emailController.text,
                          age: int.tryParse(ageController.text) ?? 28,
                          weightKg:
                              double.tryParse(weightController.text) ?? 65,
                          heightCm: double.tryParse(heightController.text) ?? 0,
                          goal: goalController.text,
                          avatarUrl: controller.profileAvatarUrl,
                        ),
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: Text(
                controller.isSavingProfile ? 'Guardando...' : 'Guardar',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({required this.item});

  final ProfileInfoItem item;

  @override
  Widget build(BuildContext context) {
    final isCompact = item.label == 'Edad' || item.label == 'Peso';

    return SizedBox(
      width: isCompact ? 110 : 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(item.icon, size: 16, color: AppColors.muted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({required this.item});

  final ProfileStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          item.value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 10),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F1E8),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
