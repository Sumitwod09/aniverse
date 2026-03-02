import '../models/anime.dart';
import '../models/anime_filters.dart';
import '../models/paginated_response.dart';
import '../services/jikan_service.dart';
import 'anime_repository.dart';

class AnimeRepositoryImpl implements AnimeRepository {
  final JikanService _jikanService;

  AnimeRepositoryImpl({JikanService? jikanService})
      : _jikanService = jikanService ?? JikanService();

  @override
  Future<PaginatedResponse<Anime>> getTopAnime({int page = 1}) {
    return _jikanService.getTopAnime(page: page);
  }

  @override
  Future<PaginatedResponse<Anime>> getSeasonalAnime({
    int? year,
    String? season,
    int page = 1,
  }) {
    return _jikanService.getSeasonalAnime(
      year: year,
      season: season,
      page: page,
    );
  }

  @override
  Future<PaginatedResponse<Anime>> getUpcomingAnime({int page = 1}) {
    return _jikanService.getUpcomingAnime(page: page);
  }

  @override
  Future<AnimeDetail> getAnimeDetail(int id) {
    return _jikanService.getAnimeDetail(id);
  }

  @override
  Future<PaginatedResponse<Episode>> getEpisodes(int animeId, {int page = 1}) {
    return _jikanService.getEpisodes(animeId, page: page);
  }

  @override
  Future<List<Schedule>> getSchedule({String? filter}) {
    return _jikanService.getSchedule(filter: filter);
  }

  @override
  Future<PaginatedResponse<Anime>> searchAnime(
    String query, {
    AnimeFilters? filters,
    int page = 1,
  }) {
    return _jikanService.searchAnime(query, filters: filters, page: page);
  }
}
