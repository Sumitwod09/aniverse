import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'download_item.freezed.dart';
part 'download_item.g.dart';

@HiveType(typeId: 1)
enum DownloadStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  downloading,
  @HiveField(2)
  paused,
  @HiveField(3)
  completed,
  @HiveField(4)
  failed,
}

@freezed
class DownloadItem with _$DownloadItem {
  @HiveType(typeId: 0, adapterName: 'DownloadItemAdapter')
  const factory DownloadItem({
    @HiveField(0) required String id,
    @HiveField(1) required String animeId,
    @HiveField(2) required String animeTitle,
    @HiveField(3) required int episodeNumber,
    @HiveField(4) required String episodeTitle,
    @HiveField(5) required String downloadUrl,
    @HiveField(6) String? localPath,
    @HiveField(7) @Default(DownloadStatus.pending) DownloadStatus status,
    @HiveField(8) double? progress,
    @HiveField(9) int? totalBytes,
    @HiveField(10) int? downloadedBytes,
    @HiveField(11) DateTime? createdAt,
    @HiveField(12) DateTime? completedAt,
    @HiveField(13) String? thumbnailUrl,
    @HiveField(14) String? quality,
  }) = _DownloadItem;

  factory DownloadItem.fromJson(Map<String, dynamic> json) =>
      _$DownloadItemFromJson(json);
}
