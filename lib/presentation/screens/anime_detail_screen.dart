import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/providers/anime_providers.dart';
import '../widgets/anime_card.dart';
import '../widgets/buttons.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_skeleton.dart';

class AnimeDetailScreen extends ConsumerWidget {
  final int animeId;

  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeDetail = ref.watch(animeDetailProvider(animeId));
    final episodes = ref.watch(episodesProvider(animeId));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: animeDetail.when(
        data: (anime) => CustomScrollView(
          slivers: [
            // Hero Image with AppBar
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero Image
                    if (anime.bannerImage != null || anime.coverImage != null)
                      Image.network(
                        anime.bannerImage ?? anime.coverImage!,
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
                      anime.title,
                      style: AppTypography.display,
                    ),
                    if (anime.titleEnglish != null && anime.titleEnglish != anime.title) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        anime.titleEnglish!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),

                    // Rating & Info Row
                    Row(
                      children: [
                        if (anime.score != null)
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
                                  anime.score!.toStringAsFixed(1),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.ctaSuccess,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: AppSpacing.md),
                        if (anime.episodes != null)
                          Text(
                            '${anime.episodes} Episodes',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(width: AppSpacing.md),
                        if (anime.duration != null)
                          Text(
                            anime.duration!,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Genre Chips
                    if (anime.genres != null && anime.genres!.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: anime.genres!
                            .map((genre) => Chip(
                                  label: Text(genre),
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
                            text: 'Watch Now',
                            icon: Icons.play_arrow,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SecondaryButton(
                            text: 'My List',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.download),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.cardBackground,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Synopsis
                    Text('Synopsis', style: AppTypography.subheading),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      anime.synopsis ?? 'No synopsis available.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Info Grid
                    _InfoGrid(anime: anime),
                    const SizedBox(height: AppSpacing.lg),

                    // Episodes Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Episodes', style: AppTypography.subheading),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),

            // Episodes List
            episodes.when(
              data: (response) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final episode = response.data[index];
                    return _EpisodeTile(episode: episode);
                  },
                  childCount: response.data.take(10).length,
                ),
              ),
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const ListItemSkeleton(),
                  childCount: 3,
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(child: Text('Failed to load episodes')),
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
              Text('Failed to load anime details', style: AppTypography.subheading),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(animeDetailProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final AnimeDetail anime;

  const _InfoGrid({required this.anime});

  @override
  Widget build(BuildContext context) {
    final infoItems = [
      if (anime.type != null) {'label': 'Type', 'value': anime.type},
      if (anime.status != null) {'label': 'Status', 'value': anime.status},
      if (anime.airedFrom != null)
        {'label': 'Aired', 'value': _formatDate(anime.airedFrom!)},
      if (anime.studios != null && anime.studios!.isNotEmpty)
        {'label': 'Studio', 'value': anime.studios!.first},
      if (anime.source != null) {'label': 'Source', 'value': anime.source},
      if (anime.rating != null) {'label': 'Rating', 'value': anime.rating},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        final item = infoItems[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['label']!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item['value']!,
              style: AppTypography.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}';
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;

  const _EpisodeTile({required this.episode});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          height: 60,
          color: AppColors.cardBackground,
          child: episode.thumbnail != null
              ? Image.network(
                  episode.thumbnail!,
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Icon(Icons.play_circle_outline,
                      color: AppColors.textMuted),
                ),
        ),
      ),
      title: Text(
        'Episode ${episode.number}',
        style: AppTypography.bodyMedium,
      ),
      subtitle: Text(
        episode.title ?? 'No title',
        style: AppTypography.caption,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: episode.duration != null
          ? Text(
              episode.duration!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            )
          : null,
      onTap: () {},
    );
  }
}
