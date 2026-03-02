import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';

class ReviewsScreen extends ConsumerWidget {
  final String contentId;
  final String contentType;
  final String title;

  const ReviewsScreen({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement reviews provider
    final reviews = <dynamic>[]; // Placeholder

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Reviews',
        actions: [
          TextButton.icon(
            onPressed: () {
              _showWriteReviewDialog(context);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Write'),
          ),
        ],
      ),
      body: reviews.isEmpty
          ? _EmptyReviewsState(
              onWriteReview: () => _showWriteReviewDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return const _ReviewCard(); // Placeholder
              },
            ),
    );
  }

  void _showWriteReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Write a Review', style: AppTypography.subheading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () {},
                  color: AppColors.ctaSuccess,
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            // Review text
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Spoiler checkbox
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                Text(
                  'Contains spoilers',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.cardBackground,
                  child: const Icon(Icons.person, color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name',
                        style: AppTypography.bodyMedium,
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              size: 14,
                              color: AppColors.ctaSuccess,
                            );
                          }),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '2 days ago',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Review text
            Text(
              'This is a placeholder review text. The actual review content would go here.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: const Text('Helpful (0)'),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReviewsState extends StatelessWidget {
  final VoidCallback onWriteReview;

  const _EmptyReviewsState({required this.onWriteReview});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rate_review, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No reviews yet', style: AppTypography.subheading),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Be the first to share your thoughts!',
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onWriteReview,
              icon: const Icon(Icons.edit),
              label: const Text('Write a Review'),
            ),
          ],
        ),
      ),
    );
  }
}
