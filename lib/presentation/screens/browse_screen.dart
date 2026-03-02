import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/models/anime_filters.dart';
import '../../data/providers/anime_providers.dart';
import '../widgets/anime_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_bar.dart' as app_widgets;
import '../widgets/shimmer_skeleton.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'TV', 'Movie', 'OVA'];
  String _selectedGenre = '';

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Action', 'color': Colors.red},
    {'name': 'Adventure', 'color': Colors.orange},
    {'name': 'Comedy', 'color': Colors.yellow},
    {'name': 'Drama', 'color': Colors.purple},
    {'name': 'Fantasy', 'color': Colors.green},
    {'name': 'Horror', 'color': Colors.grey},
    {'name': 'Romance', 'color': Colors.pink},
    {'name': 'Sci-Fi', 'color': Colors.blue},
    {'name': 'Slice of Life', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final type = _tabs[_tabController.index].toLowerCase();
      final filters = AnimeFilters(
        types: type == 'all' ? null : [type],
        genres: _selectedGenre.isEmpty ? null : [_selectedGenre],
      );
      ref.read(searchFiltersProvider.notifier).state = filters;
      ref.read(searchQueryProvider.notifier).state = '';
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        onApply: (filters) {
          ref.read(searchFiltersProvider.notifier).state = filters;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Browse',
        showBackButton: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: app_widgets.SearchBarExtended(
                  hintText: 'Search by genre, studio...',
                  onFilterTap: _showFilterSheet,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.primaryAccent,
                labelColor: AppColors.primaryAccent,
                unselectedLabelColor: AppColors.textMuted,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Genre Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenre == genre['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(genre['name'] as String),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedGenre = selected ? genre['name'] as String : '');
                      final type = _tabs[_tabController.index].toLowerCase();
                      final filters = AnimeFilters(
                        types: type == 'all' ? null : [type],
                        genres: _selectedGenre.isEmpty ? null : [_selectedGenre],
                      );
                      ref.read(searchFiltersProvider.notifier).state = filters;
                    },
                    backgroundColor: AppColors.backgroundSurface,
                    selectedColor: (genre['color'] as Color).withOpacity(0.3),
                    checkmarkColor: genre['color'] as Color,
                    side: BorderSide(
                      color: isSelected
                          ? (genre['color'] as Color)
                          : AppColors.borderDivider,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((_) => const _BrowseContent()).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseContent extends ConsumerWidget {
  const _BrowseContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final topAnime = ref.watch(topAnimeProvider(1));

    return topAnime.when(
      data: (response) => GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: response.data.length,
        itemBuilder: (context, index) {
          final anime = response.data[index];
          return AnimeCard(
            imageUrl: anime.coverImage ?? 'https://via.placeholder.com/120x180?text=No+Image',
            title: anime.title,
            rating: anime.score,
            hasSub: true,
            hasDub: anime.episodes != null && anime.episodes! > 12,
            onTap: () {},
          );
        },
      ),
      loading: () => GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const AnimeCardSkeleton(),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('Failed to load', style: AppTypography.subheading),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Function(AnimeFilters) onApply;

  const _FilterBottomSheet({required this.onApply});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _selectedYear;
  String? _selectedStatus;
  String? _selectedRating;
  String? _selectedOrder;

  final List<String> _years = ['2024', '2023', '2022', '2021', '2020'];
  final List<String> _statuses = ['Airing', 'Finished', 'Upcoming'];
  final List<String> _ratings = ['G', 'PG', 'PG-13', 'R', 'R+'];
  final List<String> _orders = ['Score', 'Popularity', 'Start Date'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text('Filters', style: AppTypography.heading),
          SizedBox(height: AppSpacing.lg),
          Text('Year', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _years.map((year) => ChoiceChip(
              label: Text(year),
              selected: _selectedYear == year,
              onSelected: (selected) => setState(() => _selectedYear = selected ? year : null),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Status', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _statuses.map((status) => ChoiceChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (selected) => setState(() => _selectedStatus = selected ? status : null),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Rating', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _ratings.map((rating) => ChoiceChip(
              label: Text(rating),
              selected: _selectedRating == rating,
              onSelected: (selected) => setState(() => _selectedRating = selected ? rating : null),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Sort By', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _orders.map((order) => ChoiceChip(
              label: Text(order),
              selected: _selectedOrder == order,
              onSelected: (selected) => setState(() => _selectedOrder = selected ? order : null),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final filters = AnimeFilters(
                      year: _selectedYear != null ? int.parse(_selectedYear!) : null,
                      statuses: _selectedStatus != null ? [_selectedStatus!.toLowerCase()] : null,
                      rating: _selectedRating,
                      orderBy: _selectedOrder?.toLowerCase().replaceAll(' ', '_'),
                    );
                    widget.onApply(filters);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
