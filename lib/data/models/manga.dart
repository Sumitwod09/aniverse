import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';
part 'manga.g.dart';

@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,
    required String title,
    String? description,
    String? coverImage,
    String? bannerImage,
    double? rating,
    String? status,
    int? year,
    String? contentRating,
    List<String>? tags,
    List<String>? authors,
    List<String>? artists,
    String? originalLanguage,
    int? chapterCount,
    int? volumeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

@freezed
class MangaDetail with _$MangaDetail {
  const factory MangaDetail({
    required String id,
    required String title,
    String? description,
    String? coverImage,
    String? bannerImage,
    double? rating,
    String? status,
    int? year,
    String? contentRating,
    List<String>? tags,
    List<String>? authors,
    List<String>? artists,
    String? originalLanguage,
    int? chapterCount,
    int? volumeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Chapter>? chapters,
  }) = _MangaDetail;

  factory MangaDetail.fromJson(Map<String, dynamic> json) =>
      _$MangaDetailFromJson(json);
}

@freezed
class Chapter with _$Chapter {
  const factory Chapter({
    required String id,
    required String mangaId,
    required String title,
    String? volume,
    String? chapter,
    int? pageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readableAt,
    String? scanlationGroup,
    bool? isExternal,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);
}

@freezed
class ChapterPages with _$ChapterPages {
  const factory ChapterPages({
    required String chapterId,
    required List<String> pages,
    String? baseUrl,
    String? hash,
  }) = _ChapterPages;

  factory ChapterPages.fromJson(Map<String, dynamic> json) =>
      _$ChapterPagesFromJson(json);
}
