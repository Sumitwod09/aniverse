import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/manga.dart';
import '../../data/providers/manga_providers.dart';
import '../widgets/manga_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_skeleton.dart';

class MangaBrowseScreen extends ConsumerStatefulWidget {
  const MangaBrowseScreen({super.key});

  @override
  ConsumerState<MangaBrowseScreen> createState() => _MangaBrowseScreenState();
}

class _MangaBrowseScreenState extends ConsumerState<MangaBrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(mangaSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Manga',
        showBackButton: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryAccent,
            labelColor: AppColors.primaryAccent,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'Popular'),
              Tab(text: 'Latest'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: (value) {
                ref.read(mangaSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(mangaSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Content
          Expanded(
            child: searchQuery.isNotEmpty
                ? _MangaSearchResults(query: searchQuery)
                : TabBarView(
                    controller: _tabController,
                    children: const [
                      _PopularMangaTab(),
                      _LatestMangaTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PopularMangaTab extends ConsumerWidget {
  const _PopularMangaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularManga = ref.watch(popularMangaProvider);

    return popularManga.when(
      data: (mangaList) => _MangaGrid(mangaList: mangaList),
      loading: () => const _MangaGridSkeleton(),
      error: (error, _) => _MangaErrorView(
        onRetry: () => ref.invalidate(popularMangaProvider),
      ),
    );
  }
}

class _LatestMangaTab extends ConsumerWidget {
  const _LatestMangaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestManga = ref.watch(latestMangaProvider);

    return latestManga.when(
      data: (mangaList) => _MangaGrid(mangaList: mangaList),
      loading: () => const _MangaGridSkeleton(),
      error: (error, _) => _MangaErrorView(
        onRetry: () => ref.invalidate(latestMangaProvider),
      ),
    );
  }
}

class _MangaSearchResults extends ConsumerWidget {
  final String query;

  const _MangaSearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(mangaSearchResultsProvider(query));

    return searchResults.when(
      data: (mangaList) {
        if (mangaList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No manga found for "$query"',
                  style: AppTypography.subheading,
                ),
              ],
            ),
          );
        }
        return _MangaGrid(mangaList: mangaList);
      },
      loading: () => const _MangaGridSkeleton(),
      error: (error, _) => _MangaErrorView(
        onRetry: () => ref.invalidate(mangaSearchResultsProvider(query)),
      ),
    );
  }
}

class _MangaGrid extends StatelessWidget {
  final List<Manga> mangaList;

  const _MangaGrid({required this.mangaList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: mangaList.length,
      itemBuilder: (context, index) {
        final manga = mangaList[index];
        return MangaCard(
          imageUrl: manga.coverImage ?? 'https://via.placeholder.com/120x180?text=No+Image',
          title: manga.title,
          rating: manga.rating,
          status: manga.status,
          chapterCount: manga.chapterCount,
          onTap: () {
            Navigator.pushNamed(context, '/manga/${manga.id}');
          },
        );
      },
    );
  }
}

class _MangaGridSkeleton extends StatelessWidget {
  const _MangaGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const MangaCardSkeleton(),
    );
  }
}

class _MangaErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _MangaErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Failed to load manga', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
