import 'package:freezed_annotation/freezed_annotation.dart';

part 'anime.freezed.dart';
part 'anime.g.dart';

@freezed
class Anime with _$Anime {
  const factory Anime({
    required int id,
    required String title,
    @JsonKey(name: 'title_english') String? titleEnglish,
    @JsonKey(name: 'title_japanese') String? titleJapanese,
    String? synopsis,
    @JsonKey(name: 'images') Map<String, dynamic>? images,
    double? score,
    int? episodes,
    String? status,
    String? type,
    String? rating,
    @JsonKey(name: 'year') int? year,
    @JsonKey(name: 'genres') List<dynamic>? genres,
    @JsonKey(name: 'studios') List<dynamic>? studios,
    int? members,
    int? favorites,
    String? duration,
    String? source,
    @JsonKey(name: 'aired') Map<String, dynamic>? aired,
  }) = _Anime;

  factory Anime.fromJson(Map<String, dynamic> json) => _$AnimeFromJson(json);
}

// Extension for computed properties
extension AnimeExtension on Anime {
  String? get coverImage {
    final images = this.images;
    if (images != null && images['jpg'] != null) {
      return images['jpg']['image_url'] as String?;
    }
    return null;
  }

  String? get bannerImage {
    final images = this.images;
    if (images != null && images['jpg'] != null) {
      return images['jpg']['large_image_url'] as String?;
    }
    return null;
  }

  List<String> get genreNames {
    if (genres == null) return [];
    return genres!
        .map((genre) => genre['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  DateTime? get airedFrom {
    final aired = this.aired;
    if (aired != null && aired['from'] != null) {
      final from = aired['from'] as String?;
      if (from != null) {
        try {
          return DateTime.parse(from);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  DateTime? get airedTo {
    final aired = this.aired;
    if (aired != null && aired['to'] != null) {
      final to = aired['to'] as String?;
      if (to != null) {
        try {
          return DateTime.parse(to);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }
}

@freezed
class AnimeDetail with _$AnimeDetail {
  const factory AnimeDetail({
    required int id,
    required String title,
    String? titleEnglish,
    String? titleJapanese,
    String? synopsis,
    String? coverImage,
    String? bannerImage,
    double? score,
    int? episodes,
    String? status,
    String? type,
    String? rating,
    int? year,
    List<String>? genres,
    List<String>? studios,
    List<String>? producers,
    List<String>? licensors,
    int? members,
    int? favorites,
    String? duration,
    String? source,
    DateTime? airedFrom,
    DateTime? airedTo,
    String? trailerUrl,
    List<Episode>? episodesList,
  }) = _AnimeDetail;

  factory AnimeDetail.fromJson(Map<String, dynamic> json) =>
      _$AnimeDetailFromJson(json);
}

@freezed
class Episode with _$Episode {
  const factory Episode({
    required int id,
    required int number,
    String? title,
    String? synopsis,
    String? thumbnail,
    String? duration,
    DateTime? aired,
    bool? filler,
    bool? recap,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);
}

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String day,
    required List<ScheduledAnime> anime,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}

@freezed
class ScheduledAnime with _$ScheduledAnime {
  const factory ScheduledAnime({
    required int id,
    required String title,
    String? coverImage,
    String? time,
    int? episodeNumber,
  }) = _ScheduledAnime;

  factory ScheduledAnime.fromJson(Map<String, dynamic> json) =>
      _$ScheduledAnimeFromJson(json);
}
