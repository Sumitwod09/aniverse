import '../models/anime.dart';
import '../models/anime_filters.dart';
import '../models/paginated_response.dart';

abstract class AnimeRepository {
  Future<PaginatedResponse<Anime>> getTopAnime({int page = 1});
  Future<PaginatedResponse<Anime>> getSeasonalAnime({int? year, String? season, int page = 1});
  Future<PaginatedResponse<Anime>> getUpcomingAnime({int page = 1});
  Future<AnimeDetail> getAnimeDetail(int id);
  Future<PaginatedResponse<Episode>> getEpisodes(int animeId, {int page = 1});
  Future<List<Schedule>> getSchedule({String? filter});
  Future<PaginatedResponse<Anime>> searchAnime(String query, {AnimeFilters? filters, int page = 1});
}
