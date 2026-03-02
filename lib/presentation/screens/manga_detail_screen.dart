import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/manga.dart';
import '../../data/providers/manga_providers.dart';
import '../widgets/buttons.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_skeleton.dart';

class MangaDetailScreen extends ConsumerWidget {
  final String mangaId;

  const MangaDetailScreen({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaDetail = ref.watch(mangaDetailProvider(mangaId));
    final chapters = ref.watch(mangaChaptersProvider(mangaId));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: mangaDetail.when(
        data: (manga) => CustomScrollView(
          slivers: [
            // Cover Image with AppBar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image
                    if (manga.coverImage != null)
                      Image.network(
                        manga.coverImage!,
                        fit: BoxFit.cover,
                      ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.backgroundPrimary.withOpacity(0.8),
                            AppColors.backgroundPrimary,
                          ],
                          stops: const [0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.arrow_back_ios, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.share, size: 20),
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      manga.title,
                      style: AppTypography.display,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Rating & Info Row
                    Row(
                      children: [
                        if (manga.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ctaSuccess.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.ctaSuccess,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  manga.rating!.toStringAsFixed(1),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.ctaSuccess,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: AppSpacing.md),
                        if (manga.chapterCount != null)
                          Text(
                            '${manga.chapterCount} Chapters',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Status & Year
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        if (manga.status != null)
                          Chip(
                            label: Text(manga.status!),
                            backgroundColor: AppColors.cardBackground.withOpacity(0.5),
                          ),
                        if (manga.year != null)
                          Chip(
                            label: Text('${manga.year}'),
                            backgroundColor: AppColors.cardBackground.withOpacity(0.5),
                          ),
                        if (manga.contentRating != null)
                          Chip(
                            label: Text(manga.contentRating!),
                            backgroundColor: AppColors.cardBackground.withOpacity(0.5),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Genre Tags
                    if (manga.tags != null && manga.tags!.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: manga.tags!
                            .take(10)
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor:
                                      AppColors.cardBackground.withOpacity(0.5),
                                  side: BorderSide.none,
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: AppSpacing.lg),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PrimaryButton(
                            text: 'Start Reading',
                            icon: Icons.menu_book,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SecondaryButton(
                            text: 'Bookmark',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    Text('Synopsis', style: AppTypography.subheading),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      manga.description ?? 'No description available.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Chapters Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chapters', style: AppTypography.subheading),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Sort'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),

            // Chapters List
            chapters.when(
              data: (chapterList) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapterList[index];
                    return _ChapterTile(chapter: chapter);
                  },
                  childCount: chapterList.length,
                ),
              ),
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const ListItemSkeleton(),
                  childCount: 5,
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(child: Text('Failed to load chapters')),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Failed to load manga details', style: AppTypography.subheading),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(mangaDetailProvider(mangaId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;

  const _ChapterTile({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      title: Text(
        chapter.title,
        style: AppTypography.bodyMedium,
      ),
      subtitle: Row(
        children: [
          if (chapter.scanlationGroup != null)
            Text(
              chapter.scanlationGroup!,
              style: AppTypography.caption,
            ),
          if (chapter.scanlationGroup != null && chapter.pageCount != null)
            const SizedBox(width: AppSpacing.sm),
          if (chapter.pageCount != null)
            Text(
              '${chapter.pageCount} pages',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.isExternal == true)
            const Icon(Icons.open_in_new, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/reader/${chapter.id}',
          arguments: {'chapter': chapter},
        );
      },
    );
  }
}
