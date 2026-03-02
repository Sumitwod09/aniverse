import 'package:dio/dio.dart';
import '../models/manga.dart';
import '../models/api_error.dart';
import 'dio_client.dart';

class MangaDexService {
  final Dio _dio = DioClient.instance;
  final String _baseUrl = 'https://api.mangadex.org';

  /// Get manga list with filters
  Future<List<Manga>> getMangaList({
    int limit = 20,
    int offset = 0,
    String? title,
    List<String>? tags,
    String? status,
    String? contentRating,
    String? order,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'includes[]': 'cover_art',
        'availableTranslatedLanguage[]': 'en',
      };

      if (title != null && title.isNotEmpty) {
        params['title'] = title;
      }
      if (status != null) {
        params['status[]'] = status;
      }
      if (contentRating != null) {
        params['contentRating[]'] = contentRating;
      } else {
        params['contentRating[]'] = ['safe', 'suggestive'];
      }

      final response = await _dio.get(
        '$_baseUrl/manga',
        queryParameters: params,
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      return data.map((json) => _mapManga(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get manga details
  Future<MangaDetail> getMangaDetail(String mangaId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/manga/$mangaId',
        queryParameters: {
          'includes[]': 'cover_art',
        },
      );

      final manga = _mapMangaDetail(response.data['data'] as Map<String, dynamic>);
      return manga;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get chapters for a manga
  Future<List<Chapter>> getMangaChapters(
    String mangaId, {
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/chapter',
        queryParameters: {
          'manga': mangaId,
          'limit': limit,
          'offset': offset,
          'translatedLanguage[]': 'en',
          'order[chapter]': 'desc',
          'includes[]': 'scanlation_group',
        },
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      return data.map((json) => _mapChapter(json, mangaId)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get chapter pages
  Future<ChapterPages> getChapterPages(String chapterId) async {
    try {
      final response = await _dio.get('$_baseUrl/at-home/server/$chapterId');
      
      final baseUrl = response.data['baseUrl'] as String;
      final chapterData = response.data['chapter'] as Map<String, dynamic>;
      final hash = chapterData['hash'] as String;
      final pages = (chapterData['data'] as List).cast<String>();

      final fullUrls = pages
          .map((page) => '$baseUrl/data/$hash/$page')
          .toList();

      return ChapterPages(
        chapterId: chapterId,
        pages: fullUrls,
        baseUrl: baseUrl,
        hash: hash,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Search manga by title
  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    return getMangaList(title: query, limit: limit);
  }

  /// Get popular manga
  Future<List<Manga>> getPopularManga({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/manga',
        queryParameters: {
          'limit': limit,
          'includes[]': 'cover_art',
          'availableTranslatedLanguage[]': 'en',
          'order[followedCount]': 'desc',
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      return data.map((json) => _mapManga(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get latest updates
  Future<List<Manga>> getLatestUpdates({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/manga',
        queryParameters: {
          'limit': limit,
          'includes[]': 'cover_art',
          'availableTranslatedLanguage[]': 'en',
          'order[latestUploadedChapter]': 'desc',
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      final data = (response.data['data'] as List).cast<Map<String, dynamic>>();
      return data.map((json) => _mapManga(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Map manga JSON to model
  Manga _mapManga(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List? ?? [];

    // Find cover art
    String? coverImage;
    final coverRelationship = relationships.firstWhere(
      (r) => r['type'] == 'cover_art',
      orElse: () => null,
    );
    if (coverRelationship != null) {
      final coverAttributes = coverRelationship['attributes'] as Map<String, dynamic>?;
      if (coverAttributes != null) {
        final fileName = coverAttributes['fileName'] as String?;
        if (fileName != null) {
          coverImage = 'https://uploads.mangadex.org/covers/${json['id']}/$fileName';
        }
      }
    }

    // Get title
    final titleMap = attributes['title'] as Map<String, dynamic>?;
    final title = (titleMap?['en'] ?? 
                  titleMap?.values.firstOrNull ?? 
                  'Unknown Title') as String;

    // Get description
    final descriptionMap = attributes['description'] as Map<String, dynamic>?;
    final description = descriptionMap?['en'] as String?;

    // Get tags
    final tags = (attributes['tags'] as List?)
        ?.map((t) {
          final tagAttr = t['attributes'] as Map<String, dynamic>?;
          final tagName = tagAttr?['name'] as Map<String, dynamic>?;
          return tagName?['en'] as String?;
        })
        .whereType<String>()
        .toList();

    return Manga(
      id: json['id'] as String,
      title: title,
      description: description,
      coverImage: coverImage,
      rating: (attributes['rating']?['average'] as num?)?.toDouble(),
      status: attributes['status'] as String?,
      year: attributes['year'] as int?,
      contentRating: attributes['contentRating'] as String?,
      tags: tags,
      chapterCount: attributes['lastChapter'] != null
          ? int.tryParse(attributes['lastChapter'] as String)
          : null,
      updatedAt: attributes['updatedAt'] != null
          ? DateTime.parse(attributes['updatedAt'] as String)
          : null,
      createdAt: attributes['createdAt'] != null
          ? DateTime.parse(attributes['createdAt'] as String)
          : null,
    );
  }

  /// Map manga detail
  MangaDetail _mapMangaDetail(Map<String, dynamic> json) {
    final manga = _mapManga(json);
    return MangaDetail(
      id: manga.id,
      title: manga.title,
      description: manga.description,
      coverImage: manga.coverImage,
      bannerImage: manga.bannerImage,
      rating: manga.rating,
      status: manga.status,
      year: manga.year,
      contentRating: manga.contentRating,
      tags: manga.tags,
      authors: manga.authors,
      artists: manga.artists,
      originalLanguage: manga.originalLanguage,
      chapterCount: manga.chapterCount,
      volumeCount: manga.volumeCount,
      createdAt: manga.createdAt,
      updatedAt: manga.updatedAt,
    );
  }

  /// Map chapter JSON to model
  Chapter _mapChapter(Map<String, dynamic> json, String mangaId) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List? ?? [];

    // Find scanlation group
    String? scanlationGroup;
    final groupRelationship = relationships.firstWhere(
      (r) => r['type'] == 'scanlation_group',
      orElse: () => null,
    );
    if (groupRelationship != null) {
      final groupAttrs = groupRelationship['attributes'] as Map<String, dynamic>?;
      scanlationGroup = groupAttrs?['name'] as String?;
    }

    return Chapter(
      id: json['id'] as String,
      mangaId: mangaId,
      title: (attributes['title'] ?? 'Chapter ${attributes['chapter'] ?? '?'}') as String,
      volume: attributes['volume'] as String?,
      chapter: attributes['chapter'] as String?,
      pageCount: attributes['pages'] as int?,
      createdAt: attributes['createdAt'] != null
          ? DateTime.parse(attributes['createdAt'] as String)
          : null,
      updatedAt: attributes['updatedAt'] != null
          ? DateTime.parse(attributes['updatedAt'] as String)
          : null,
      readableAt: attributes['readableAt'] != null
          ? DateTime.parse(attributes['readableAt'] as String)
          : null,
      scanlationGroup: scanlationGroup,
      isExternal: attributes['externalUrl'] != null,
    );
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
