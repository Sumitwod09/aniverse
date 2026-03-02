import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/download_item.dart';
import 'dio_client.dart';

class DownloadService {
  final Dio _dio = DioClient.instance;

  /// Download directory for saved videos
  Future<Directory> get _downloadDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// Start downloading an episode
  Future<DownloadItem> startDownload(DownloadItem item) async {
    final dir = await _downloadDir;
    final fileName =
        '${item.animeTitle}_ep${item.episodeNumber}_${item.quality ?? '1080p'}.mp4'
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(RegExp(r'\s+'), '_');
    final localPath = '${dir.path}/$fileName';

    try {
      await _dio.download(
        item.downloadUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toDouble();
            _onProgressUpdate?.call(item.id, progress, received, total.toInt());
          }
        },
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return item.copyWith(
        status: DownloadStatus.completed,
        localPath: localPath,
        completedAt: DateTime.now(),
        progress: 100.0,
      );
    } catch (e) {
      return item.copyWith(
        status: DownloadStatus.failed,
        progress: item.progress ?? 0.0,
      );
    }
  }

  /// Cancel an active download
  Future<void> cancelDownload(String downloadId) async {
    // Cancel the download using cancel token
  }

  /// Delete a downloaded file
  Future<bool> deleteDownload(DownloadItem item) async {
    try {
      if (item.localPath != null && await File(item.localPath!).exists()) {
        await File(item.localPath!).delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if file exists locally
  Future<bool> isDownloaded(DownloadItem item) async {
    if (item.localPath == null) return false;
    return File(item.localPath!).existsSync();
  }

  /// Get download progress callback
  Function(String id, double progress, int received, int total)? _onProgressUpdate;

  void setOnProgressUpdate(
    Function(String id, double progress, int received, int total) callback,
  ) {
    _onProgressUpdate = callback;
  }

  /// Get available disk space
  Future<int> getAvailableSpace() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stat = await dir.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Get total used space by downloads
  Future<int> getUsedSpace() async {
    try {
      final dir = await _downloadDir;
      int totalSize = 0;
      
      await for (final entity in dir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human readable string
  String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength ~/ 10).clamp(0, suffixes.length - 1);
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
