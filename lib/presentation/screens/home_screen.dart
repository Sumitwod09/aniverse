import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/models/paginated_response.dart';
import '../../data/providers/anime_providers.dart';
import '../widgets/anime_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/shimmer_skeleton.dart';
import 'browse_screen.dart';
import 'search_screen.dart';
import 'manga_browse_screen.dart';
import 'downloads_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _AnimeHomeTab(), // Home tab
      const BrowseScreen(), // Browse tab
      const MangaBrowseScreen(), // Manga tab
      const DownloadsScreen(), // Downloads tab
      const ProfileScreen(), // Profile tab
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.invalidate(topAnimeProvider);
    ref.invalidate(seasonalAnimeProvider);
    ref.invalidate(upcomingAnimeProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// Separate widget for the anime home content
class _AnimeHomeTab extends ConsumerWidget {
  const _AnimeHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ScrollController();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(topAnimeProvider);
        ref.invalidate(seasonalAnimeProvider);
        ref.invalidate(upcomingAnimeProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primaryAccent,
      backgroundColor: AppColors.cardBackground,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AniVerse',
                      style: AppTypography.display,
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Hero Section - Trending
          const SliverToBoxAdapter(
            child: _HeroSection(),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.filter_list,
                      label: 'Filters',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.new_releases,
                      label: 'Latest',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.calendar_today,
                      label: 'Schedule',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Top Rated Section
          SliverToBoxAdapter(
            child: _AnimeSection(
              title: 'Top Rated',
              provider: topAnimeProvider(1),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Seasonal Section
          SliverToBoxAdapter(
            child: _AnimeSection(
              title: 'Seasonal Anime',
              provider: seasonalAnimeProvider,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Upcoming Section
          SliverToBoxAdapter(
            child: _AnimeSection(
              title: 'Upcoming',
              provider: upcomingAnimeProvider(1),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _HeroSection extends ConsumerWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topAnime = ref.watch(topAnimeProvider(1));

    return topAnime.when(
      data: (response) {
        final anime = response.data.take(5).toList();
        if (anime.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: anime.length,
            itemBuilder: (context, index) {
              final item = anime[index];
              return _HeroCard(anime: item);
            },
          ),
        );
      },
      loading: () => const HeroSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Anime anime;

  const _HeroCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: anime.bannerImage != null
            ? DecorationImage(
                image: NetworkImage(anime.bannerImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.heroGradient,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anime.title,
              style: AppTypography.heading,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (anime.genreNames.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                children: anime.genreNames
                    .take(3)
                    .map((genre) => Chip(
                          label: Text(genre),
                          backgroundColor: AppColors.cardBackground.withOpacity(0.7),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Watch Now'),
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimeSection extends ConsumerWidget {
  final String title;
  final ProviderListenable<AsyncValue<PaginatedResponse<Anime>>> provider;

  const _AnimeSection({
    required this.title,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeData = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.subheading),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: animeData.when(
            data: (response) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: response.data.length,
              itemBuilder: (context, index) {
                final anime = response.data[index];
                return AnimeCard(
                  imageUrl: anime.coverImage ??
                      'https://via.placeholder.com/120x180?text=No+Image',
                  title: anime.title,
                  rating: anime.score,
                  hasSub: true,
                  hasDub: anime.episodes != null && anime.episodes! > 12,
                  onTap: () {},
                );
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 5,
              itemBuilder: (context, index) => const AnimeCardSkeleton(),
            ),
            error: (error, _) => Center(
              child: Text(
                'Failed to load',
                style: AppTypography.caption.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryAccent),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.captionMedium),
          ],
        ),
      ),
    );
  }
}
