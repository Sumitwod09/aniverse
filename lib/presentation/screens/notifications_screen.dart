import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement notifications provider
    final notifications = <dynamic>[]; // Placeholder

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotificationsState()
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return const _NotificationCard(); // Placeholder
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications,
            color: AppColors.primaryAccent,
          ),
        ),
        title: Text(
          'New Episode Available',
          style: AppTypography.bodyMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Episode 12 of Attack on Titan is now available',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '2 hours ago',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to content
        },
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No notifications', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'re all caught up!',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
