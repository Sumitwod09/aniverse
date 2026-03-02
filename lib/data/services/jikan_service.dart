import 'package:dio/dio.dart';
import '../models/anime.dart';
import '../models/anime_filters.dart';
import '../models/api_error.dart';
import '../models/paginated_response.dart';
import 'dio_client.dart';

class JikanService {
  final Dio _dio = DioClient.instance;
  final String _baseUrl = 'https://api.jikan.moe/v4';

  Future<PaginatedResponse<Anime>> getTopAnime({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/top/anime',
        queryParameters: {'page': page},
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      return PaginatedResponse(
        data: data.map((json) => Anime.fromJson(json)).toList(),
        pagination: Pagination.fromJson(pagination),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PaginatedResponse<Anime>> getSeasonalAnime({
    int? year,
    String? season,
    int page = 1,
  }) async {
    try {
      final String url;
      if (year != null && season != null) {
        url = '$_baseUrl/seasons/$year/$season';
      } else {
        url = '$_baseUrl/seasons/now';
      }

      final response = await _dio.get(
        url,
        queryParameters: {'page': page},
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      return PaginatedResponse(
        data: data.map((json) => Anime.fromJson(json)).toList(),
        pagination: Pagination.fromJson(pagination),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PaginatedResponse<Anime>> getUpcomingAnime({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/seasons/upcoming',
        queryParameters: {'page': page},
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      return PaginatedResponse(
        data: data.map((json) => Anime.fromJson(json)).toList(),
        pagination: Pagination.fromJson(pagination),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AnimeDetail> getAnimeDetail(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/anime/$id/full');
      return AnimeDetail.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PaginatedResponse<Episode>> getEpisodes(
    int animeId, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/$animeId/episodes',
        queryParameters: {'page': page},
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      return PaginatedResponse(
        data: data.map((json) => Episode.fromJson(json)).toList(),
        pagination: Pagination.fromJson(pagination),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Schedule>> getSchedule({String? filter}) async {
    try {
      final params = <String, dynamic>{};
      if (filter != null) params['filter'] = filter;

      final response = await _dio.get(
        '$_baseUrl/schedules',
        queryParameters: params,
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();

      return data.map((json) => Schedule.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PaginatedResponse<Anime>> searchAnime(
    String query, {
    AnimeFilters? filters,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'page': page,
      };

      if (filters != null) {
        params.addAll(filters.toQueryParams());
      }

      final response = await _dio.get(
        '$_baseUrl/anime',
        queryParameters: params,
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      return PaginatedResponse(
        data: data.map((json) => Anime.fromJson(json)).toList(),
        pagination: Pagination.fromJson(pagination),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiError.network();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return const ApiError.notFound();
        } else if (statusCode == 429) {
          return const ApiError.rateLimit();
        } else if (statusCode != null && statusCode >= 500) {
          return ApiError.server(statusCode: statusCode);
        }
        return ApiError.server(statusCode: statusCode ?? 500);
      default:
        return ApiError.unknown(message: error.message);
    }
  }
}
