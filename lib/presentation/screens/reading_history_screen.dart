import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/reading_progress.dart';
import '../../data/providers/reading_progress_providers.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_skeleton.dart';

class ReadingHistoryScreen extends ConsumerWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentReading = ref.watch(recentReadingProvider);
    final bookmarks = ref.watch(bookmarksProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: CustomAppBar(
          title: 'Library',
          showBackButton: false,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              indicatorColor: AppColors.primaryAccent,
              labelColor: AppColors.primaryAccent,
              unselectedLabelColor: AppColors.textMuted,
              tabs: [
                Tab(text: 'Continue Reading'),
                Tab(text: 'Bookmarks'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _ContinueReadingTab(recentReading: recentReading),
            _BookmarksTab(bookmarksAsync: bookmarks),
          ],
        ),
      ),
    );
  }
}

class _ContinueReadingTab extends StatelessWidget {
  final List<ReadingProgress> recentReading;

  const _ContinueReadingTab({required this.recentReading});

  @override
  Widget build(BuildContext context) {
    if (recentReading.isEmpty) {
      return _EmptyState(
        icon: Icons.menu_book,
        title: 'No reading history',
        subtitle: 'Start reading manga to see your progress here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: recentReading.length,
      itemBuilder: (context, index) {
        final progress = recentReading[index];
        return _ReadingProgressCard(progress: progress);
      },
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  final AsyncValue<List<Bookmark>> bookmarksAsync;

  const _BookmarksTab({required this.bookmarksAsync});

  @override
  Widget build(BuildContext context) {
    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return _EmptyState(
            icon: Icons.bookmark_border,
            title: 'No bookmarks',
            subtitle: 'Bookmark pages while reading to find them quickly',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return _BookmarkCard(bookmark: bookmark);
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) => const ListItemSkeleton(),
      ),
      error: (_, __) => _EmptyState(
        icon: Icons.error_outline,
        title: 'Failed to load bookmarks',
        subtitle: 'Please try again later',
      ),
    );
  }
}

class _ReadingProgressCard extends StatelessWidget {
  final ReadingProgress progress;

  const _ReadingProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 120,
                  color: AppColors.cardBackground,
                  child: progress.coverImage != null
                      ? Image.network(
                          progress.coverImage!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.mangaTitle,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      progress.chapterTitle,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: progress.percentageRead,
                      backgroundColor: AppColors.borderDivider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(progress.percentageRead * 100).toInt()}% • Page ${progress.currentPage}/${progress.totalPages}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Continue button
              IconButton(
                icon: const Icon(Icons.play_arrow, color: AppColors.primaryAccent),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;

  const _BookmarkCard({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.cardBackground,
                  child: bookmark.coverImage != null
                      ? Image.network(
                          bookmark.coverImage!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.bookmark, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.mangaTitle,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      bookmark.chapterTitle,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Page ${bookmark.pageNumber}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (bookmark.note != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        bookmark.note!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
