import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/models/manga.dart';
import '../widgets/anime_card.dart';
import '../widgets/manga_card.dart';
import '../widgets/custom_app_bar.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
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
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'My Library',
        showBackButton: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryAccent,
            labelColor: AppColors.primaryAccent,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(
                icon: Icon(Icons.movie),
                text: 'Watchlist',
              ),
              Tab(
                icon: Icon(Icons.menu_book),
                text: 'Reading List',
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WatchlistTab(),
          _ReadingListTab(),
        ],
      ),
    );
  }
}

class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Implement watchlist from Firebase/local storage
    final watchlist = <Anime>[]; // Placeholder

    if (watchlist.isEmpty) {
      return _EmptyState(
        icon: Icons.movie_outlined,
        title: 'Your watchlist is empty',
        subtitle: 'Add anime to your watchlist to track what you want to watch',
        action: ElevatedButton.icon(
          onPressed: () {
            // Navigate to browse
          },
          icon: const Icon(Icons.explore),
          label: const Text('Browse Anime'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final anime = watchlist[index];
        return AnimeCard(
          imageUrl: anime.coverImage ?? '',
          title: anime.title,
          rating: anime.score,
          onTap: () {
            Navigator.pushNamed(context, '/anime/${anime.id}');
          },
        );
      },
    );
  }
}

class _ReadingListTab extends StatelessWidget {
  const _ReadingListTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Implement reading list from Firebase/local storage
    final readingList = <Manga>[]; // Placeholder

    if (readingList.isEmpty) {
      return _EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Your reading list is empty',
        subtitle: 'Add manga to your reading list to track what you want to read',
        action: ElevatedButton.icon(
          onPressed: () {
            // Navigate to manga browse
          },
          icon: const Icon(Icons.explore),
          label: const Text('Browse Manga'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: readingList.length,
      itemBuilder: (context, index) {
        final manga = readingList[index];
        return MangaCard(
          imageUrl: manga.coverImage ?? '',
          title: manga.title,
          rating: manga.rating,
          chapterCount: manga.chapterCount,
          onTap: () {
            Navigator.pushNamed(context, '/manga/${manga.id}');
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
