import 'package:dio/dio.dart';
import '../models/video_source.dart';
import 'dio_client.dart';

class ConsumetService {
  final Dio _dio = DioClient.instance;
  // Default base URL - in production, this would be configurable
  final String _baseUrl = 'https://api.consumet.org';

  /// Get available streaming servers for an anime episode
  Future<List<StreamingServer>> getServers(String episodeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/gogoanime/servers',
        queryParameters: {'episodeId': episodeId},
      );

      final data = (response.data as List).cast<Map<String, dynamic>>();
      return data.map((json) => StreamingServer.fromJson(json)).toList();
    } catch (e) {
      // Return default servers if API fails
      return [
        const StreamingServer(name: 'Gogoanime', value: 'gogoanime'),
        const StreamingServer(name: 'Vidstreaming', value: 'vidstreaming'),
      ];
    }
  }

  /// Get streaming sources for a specific episode
  Future<EpisodeSource> getEpisodeSources(
    String episodeId, {
    String server = 'gogoanime',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/gogoanime/watch/$episodeId',
        queryParameters: {'server': server},
      );

      final data = response.data as Map<String, dynamic>;

      final sources = (data['sources'] as List).cast<Map<String, dynamic>>();
      final videoSources = sources
          .map((json) => VideoSource.fromJson(json))
          .toList();

      final subtitles = data['subtitles'] != null
          ? (data['subtitles'] as List)
              .cast<Map<String, dynamic>>()
              .map((json) => SubtitleTrack.fromJson(json))
              .toList()
          : null;

      return EpisodeSource(
        sources: videoSources,
        subtitles: subtitles,
        introStart: data['intro']?['start']?.toString(),
        introEnd: data['intro']?['end']?.toString(),
        outroStart: data['outro']?['start']?.toString(),
        outroEnd: data['outro']?['end']?.toString(),
      );
    } catch (e) {
      // Return mock data for development
      return EpisodeSource(
        sources: [
          VideoSource(
            url: 'https://example.com/video.mp4',
            quality: '1080p',
            provider: 'gogoanime',
            isM3U8: false,
          ),
        ],
      );
    }
  }

  /// Search for anime on streaming platforms
  Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/gogoanime/$query',
      );

      final data = response.data as Map<String, dynamic>;
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Get anime episode list
  Future<List<Map<String, dynamic>>> getAnimeEpisodes(String animeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/anime/gogoanime/episodes/$animeId',
      );

      final data = response.data as Map<String, dynamic>;
      final episodes = (data['episodes'] as List).cast<Map<String, dynamic>>();
      return episodes;
    } catch (e) {
      return [];
    }
  }
}
