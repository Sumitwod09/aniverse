import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              title ?? 'Something went wrong',
              style: AppTypography.subheading,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: 'No internet connection',
      message: 'Please check your network settings and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? action;
  final IconData icon;

  const EmptyStateView({
    super.key,
    this.title,
    this.message,
    this.action,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              title ?? 'Nothing here yet',
              style: AppTypography.subheading,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryAccent,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NotFoundView extends StatelessWidget {
  final VoidCallback? onBack;

  const NotFoundView({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: 'Page not found',
      message: 'The content you\'re looking for doesn\'t exist or has been removed.',
      icon: Icons.search_off,
      onRetry: onBack,
    );
  }
}
