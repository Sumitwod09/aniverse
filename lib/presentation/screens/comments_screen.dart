import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String contentId;
  final String contentType;

  const CommentsScreen({
    super.key,
    required this.contentId,
    required this.contentType,
  });

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement comments provider
    final comments = <dynamic>[]; // Placeholder

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Comments',
      ),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const _EmptyCommentsState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return const _CommentCard(); // Placeholder
                    },
                  ),
          ),
          // Comment input
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.borderDivider),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryAccent),
                    onPressed: () {
                      // TODO: Post comment
                      _commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.cardBackground,
                  radius: 16,
                  child: const Icon(Icons.person, size: 20, color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'User Name',
                  style: AppTypography.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '2 hours ago',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Comment text
            Text(
              'This is a placeholder comment. The actual comment content would go here.',
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
                  label: const Text('12'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCommentsState extends StatelessWidget {
  const _EmptyCommentsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No comments yet', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Be the first to start the conversation!',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
