import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anime.dart';
import '../models/anime_filters.dart';
import '../models/paginated_response.dart';
import '../repositories/anime_repository.dart';
import '../repositories/anime_repository_impl.dart';

// Repository Provider
final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  return AnimeRepositoryImpl();
});

// Top Anime Provider
final topAnimeProvider = FutureProvider.family<PaginatedResponse<Anime>, int>(
  (ref, page) async {
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getTopAnime(page: page);
  },
);

// Seasonal Anime Provider
final seasonalAnimeProvider = FutureProvider<PaginatedResponse<Anime>>(
  (ref) async {
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getSeasonalAnime();
  },
);

// Upcoming Anime Provider
final upcomingAnimeProvider = FutureProvider.family<PaginatedResponse<Anime>, int>(
  (ref, page) async {
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getUpcomingAnime(page: page);
  },
);

// Anime Detail Provider
final animeDetailProvider = FutureProvider.family<AnimeDetail, int>(
  (ref, id) async {
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getAnimeDetail(id);
  },
);

// Episodes Provider
final episodesProvider = FutureProvider.family<PaginatedResponse<Episode>, int>(
  (ref, animeId) async {
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getEpisodes(animeId);
  },
);

// Schedule Provider
final scheduleProvider = FutureProvider<List<Schedule>>(
  (ref) async {
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getSchedule();
  },
);

// Search Query Provider (State)
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search Filters Provider (State)
final searchFiltersProvider = StateProvider<AnimeFilters?>((ref) => null);

// Search Results Provider
final searchResultsProvider = FutureProvider.family<PaginatedResponse<Anime>, int>(
  (ref, page) async {
    final repository = ref.watch(animeRepositoryProvider);
    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(searchFiltersProvider);

    if (query.isEmpty) {
      return const PaginatedResponse(
        data: [],
        pagination: Pagination(
          currentPage: 1,
          lastPage: 1,
          total: 0,
          hasNextPage: false,
        ),
      );
    }

    return repository.searchAnime(query, filters: filters, page: page);
  },
);
