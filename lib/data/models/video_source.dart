import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_source.freezed.dart';
part 'video_source.g.dart';

@freezed
class VideoSource with _$VideoSource {
  const factory VideoSource({
    required String url,
    required String quality,
    required String provider,
    bool? isM3U8,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? subtitles,
  }) = _VideoSource;

  factory VideoSource.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceFromJson(json);
}

@freezed
class EpisodeSource with _$EpisodeSource {
  const factory EpisodeSource({
    required List<VideoSource> sources,
    List<SubtitleTrack>? subtitles,
    String? introStart,
    String? introEnd,
    String? outroStart,
    String? outroEnd,
  }) = _EpisodeSource;

  factory EpisodeSource.fromJson(Map<String, dynamic> json) =>
      _$EpisodeSourceFromJson(json);
}

@freezed
class SubtitleTrack with _$SubtitleTrack {
  const factory SubtitleTrack({
    required String lang,
    required String url,
  }) = _SubtitleTrack;

  factory SubtitleTrack.fromJson(Map<String, dynamic> json) =>
      _$SubtitleTrackFromJson(json);
}

@freezed
class StreamingServer with _$StreamingServer {
  const factory StreamingServer({
    required String name,
    required String value,
  }) = _StreamingServer;

  factory StreamingServer.fromJson(Map<String, dynamic> json) =>
      _$StreamingServerFromJson(json);
}
