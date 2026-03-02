import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/providers/auth_providers.dart';
import '../widgets/buttons.dart';
import '../widgets/custom_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // Header with user info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryAccent.withOpacity(0.2),
                    AppColors.backgroundPrimary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardBackground,
                      border: Border.all(
                        color: AppColors.primaryAccent,
                        width: 3,
                      ),
                    ),
                    child: user != null
                        ? const CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primaryAccent,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.textMuted,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Name
                  Text(
                    user?.displayName ?? 'Guest User',
                    style: AppTypography.display,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Email
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),

                  // Edit Profile Button
                  if (user != null)
                    SecondaryButton(
                      text: 'Edit Profile',
                      onPressed: () {
                        // Navigate to edit profile
                      },
                    ),
                ],
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  _StatCard(
                    title: 'Watched',
                    value: '0',
                    icon: Icons.movie,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(
                    title: 'Reading',
                    value: '0',
                    icon: Icons.menu_book,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(
                    title: 'Downloads',
                    value: '0',
                    icon: Icons.download,
                  ),
                ],
              ),
            ),
          ),

          // Settings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTypography.subheading),
                  const SizedBox(height: AppSpacing.md),

                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage push notifications',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    title: 'Download Settings',
                    subtitle: 'Quality, storage, Wi-Fi only',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    subtitle: 'Theme, accent color',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'Content language preferences',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    subtitle: 'Data collection, analytics',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQ, contact us',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Version, credits',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Sign Out
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PrimaryButton(
                text: 'Sign Out',
                icon: Icons.logout,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryAccent),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.subheading,
            ),
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTypography.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(
          color: AppColors.textMuted,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
