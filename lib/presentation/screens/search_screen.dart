import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/models/paginated_response.dart';
import '../../data/providers/anime_providers.dart';
import '../widgets/anime_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_bar.dart' as app_widgets;
import '../widgets/shimmer_skeleton.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    ref.read(searchQueryProvider.notifier).state = query;
    setState(() => _currentPage = 1);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = searchQuery.isEmpty
        ? const AsyncValue.data(PaginatedResponse(data: [], pagination: Pagination(currentPage: 1, lastPage: 1, total: 0, hasNextPage: false)))
        : ref.watch(searchResultsProvider(_currentPage));

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Search',
        showBackButton: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: app_widgets.SearchBar(
              controller: _searchController,
              onClear: _clearSearch,
              onSubmitted: (query) {
                ref.read(searchQueryProvider.notifier).state = query;
              },
            ),
          ),
        ),
      ),
      body: searchResults.when(
        data: (response) {
          if (searchQuery.isEmpty) {
            return const _RecentSearchesView();
          }
          if (response.data.isEmpty) {
            return const _EmptySearchView();
          }
          return _SearchResultsGrid(
            anime: response.data.cast<Anime>(),
            hasNextPage: response.pagination.hasNextPage,
            onLoadMore: () {
              if (response.pagination.hasNextPage) {
                setState(() => _currentPage++);
              }
            },
          );
        },
        loading: () => const _SearchLoadingView(),
        error: (error, _) => _SearchErrorView(onRetry: () {
          ref.invalidate(searchResultsProvider);
        }),
      ),
    );
  }
}

class _RecentSearchesView extends StatelessWidget {
  const _RecentSearchesView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Searches', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              'Attack on Titan',
              'Demon Slayer',
              'One Piece',
              'Jujutsu Kaisen',
            ].map((query) => ActionChip(
              label: Text(query),
              onPressed: () {},
              backgroundColor: AppColors.cardBackground,
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Popular Searches', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.md),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.trending_up, color: AppColors.primaryAccent),
                title: Text('Popular Anime ${index + 1}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  final List<Anime> anime;
  final bool hasNextPage;
  final VoidCallback onLoadMore;

  const _SearchResultsGrid({
    required this.anime,
    required this.hasNextPage,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: anime.length + (hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == anime.length) {
          onLoadMore();
          return const Center(child: CircularProgressIndicator());
        }
        final item = anime[index];
        return AnimeCard(
          imageUrl: item.coverImage ?? 'https://via.placeholder.com/120x180?text=No+Image',
          title: item.title,
          rating: item.score,
          hasSub: true,
          hasDub: item.episodes != null && item.episodes! > 12,
          onTap: () {},
        );
      },
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No results found', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try different keywords or check your spelling',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SearchLoadingView extends StatelessWidget {
  const _SearchLoadingView();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const AnimeCardSkeleton(),
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _SearchErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Search failed', style: AppTypography.subheading),
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
