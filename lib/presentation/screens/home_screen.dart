import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/models/paginated_response.dart';
import '../../data/providers/anime_providers.dart';
import '../widgets/anime_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/shimmer_skeleton.dart';
import 'anime_detail_screen.dart';
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

// ─── Anime Home Tab ────────────────────────────────────────────────
class _AnimeHomeTab extends ConsumerWidget {
  const _AnimeHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        slivers: [
          // ── App Bar ──
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryAccent,
                            AppColors.primaryAccent.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('AniVerse', style: AppTypography.display),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ── Hero Spotlight ──
          const SliverToBoxAdapter(child: _HeroSpotlight()),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Genre Chips ──
          const SliverToBoxAdapter(child: _GenreRow()),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Trending Now (Top Rated) ──
          SliverToBoxAdapter(
            child: _AnimeSection(
              title: '🔥 Trending Now',
              provider: topAnimeProvider(1),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Popular This Season ──
          SliverToBoxAdapter(
            child: _AnimeSection(
              title: '⭐ Popular This Season',
              provider: seasonalAnimeProvider,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Top Rated of All Time ──
          const SliverToBoxAdapter(child: _TopRatedGrid()),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Coming Soon ──
          SliverToBoxAdapter(
            child: _AnimeSection(
              title: '🗓️ Coming Soon',
              provider: upcomingAnimeProvider(1),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Hero Spotlight with Auto-Scroll ───────────────────────────────
class _HeroSpotlight extends ConsumerStatefulWidget {
  const _HeroSpotlight();

  @override
  ConsumerState<_HeroSpotlight> createState() => _HeroSpotlightState();
}

class _HeroSpotlightState extends ConsumerState<_HeroSpotlight> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final topAnime = ref.read(topAnimeProvider(1));
      topAnime.whenData((response) {
        final itemCount = response.data.take(6).length;
        if (itemCount == 0 || !mounted) return;
        _currentPage = (_currentPage + 1) % itemCount;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topAnime = ref.watch(topAnimeProvider(1));

    return topAnime.when(
      data: (response) {
        final anime = response.data.take(6).toList();
        if (anime.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: anime.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final item = anime[index];
                  return GestureDetector(
                    onTap: () => _navigateToDetail(context, item.id),
                    child: _HeroCard(anime: item),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                anime.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 24 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primaryAccent
                        : AppColors.textMuted.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: HeroSkeleton(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _navigateToDetail(BuildContext context, int animeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimeDetailScreen(animeId: animeId),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Anime anime;

  const _HeroCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (anime.bannerImage != null)
              CachedNetworkImage(
                imageUrl: anime.bannerImage!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.cardBackground),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.cardBackground),
              )
            else
              Container(
                decoration: const BoxDecoration(gradient: AppColors.cardGradient),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge row
                  Row(
                    children: [
                      if (anime.score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.ctaSuccess,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                anime.score!.toStringAsFixed(1),
                                style: AppTypography.captionMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (anime.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            anime.type!,
                            style: AppTypography.captionMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    anime.titleEnglish ?? anime.title,
                    style: AppTypography.heading.copyWith(
                      fontSize: 20,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Genre + episode count
                  Row(
                    children: [
                      if (anime.genreNames.isNotEmpty)
                        Flexible(
                          child: Text(
                            anime.genreNames.take(3).join(' • '),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (anime.episodes != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${anime.episodes} eps',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryAccent.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Genre Chips Row ───────────────────────────────────────────────
class _GenreRow extends StatelessWidget {
  const _GenreRow();

  static const _genres = [
    {'name': 'Action', 'icon': Icons.flash_on, 'color': 0xFFEF4444},
    {'name': 'Romance', 'icon': Icons.favorite, 'color': 0xFFEC4899},
    {'name': 'Comedy', 'icon': Icons.sentiment_very_satisfied, 'color': 0xFFF59E0B},
    {'name': 'Fantasy', 'icon': Icons.auto_awesome, 'color': 0xFF8B5CF6},
    {'name': 'Sci-Fi', 'icon': Icons.rocket_launch, 'color': 0xFF06B6D4},
    {'name': 'Horror', 'icon': Icons.nightlight_round, 'color': 0xFF6B7280},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': 0xFF22C55E},
    {'name': 'Slice of Life', 'icon': Icons.coffee, 'color': 0xFFF97316},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final color = Color(genre['color'] as int);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  // TODO: Navigate to genre-filtered browse
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(genre['icon'] as IconData,
                          color: color, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        genre['name'] as String,
                        style: AppTypography.captionMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Horizontal Anime Section ──────────────────────────────────────
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrowseScreen()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.primaryAccent),
                  ],
                ),
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
              itemCount: response.data.length.clamp(0, 20),
              itemBuilder: (context, index) {
                final anime = response.data[index];
                return AnimeCard(
                  imageUrl: anime.coverImage ??
                      'https://via.placeholder.com/120x180?text=No+Image',
                  title: anime.titleEnglish ?? anime.title,
                  rating: anime.score,
                  hasSub: true,
                  hasDub: anime.episodes != null && anime.episodes! > 12,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AnimeDetailScreen(animeId: anime.id),
                      ),
                    );
                  },
                );
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: AnimeCardSkeleton(),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: AppColors.textMuted, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Top Rated Grid (numbered list) ────────────────────────────────
class _TopRatedGrid extends ConsumerWidget {
  const _TopRatedGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topAnime = ref.watch(topAnimeProvider(1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🏆 Top Rated All Time',
                  style: AppTypography.subheading),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrowseScreen()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.primaryAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        topAnime.when(
          data: (response) {
            final items = response.data.take(10).toList();
            return SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final anime = items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AnimeDetailScreen(animeId: anime.id),
                        ),
                      );
                    },
                    child: Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderDivider,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Rank number
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                '#${index + 1}',
                                style: AppTypography.heading.copyWith(
                                  fontSize: 18,
                                  color: index < 3
                                      ? AppColors.primaryAccent
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          // Cover
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: anime.coverImage ??
                                  'https://via.placeholder.com/80x120',
                              width: 70,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 70,
                                height: 100,
                                color: AppColors.backgroundSurface,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 70,
                                height: 100,
                                color: AppColors.backgroundSurface,
                                child: const Icon(Icons.broken_image,
                                    color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 4),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    anime.titleEnglish ?? anime.title,
                                    style: AppTypography.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (anime.score != null) ...[
                                        const Icon(Icons.star_rounded,
                                            size: 14,
                                            color: AppColors.ctaSuccess),
                                        const SizedBox(width: 3),
                                        Text(
                                          anime.score!.toStringAsFixed(1),
                                          style: AppTypography.caption
                                              .copyWith(
                                            color: AppColors.ctaSuccess,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (anime.episodes != null)
                                        Text(
                                          '${anime.episodes} eps',
                                          style: AppTypography.caption
                                              .copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (anime.genreNames.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        anime.genreNames.take(2).join(', '),
                                        style: AppTypography.caption
                                            .copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Arrow
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.arrow_forward_ios,
                                size: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ShimmerSkeleton(
                    width: 260, height: 130, borderRadius: 14),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
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
