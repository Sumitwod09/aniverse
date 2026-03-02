import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/download_item.dart';
import '../services/download_service.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final downloadsBoxProvider = FutureProvider<Box<DownloadItem>>((ref) async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DownloadItemAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DownloadStatusAdapter());
  }
  return Hive.openBox<DownloadItem>('downloads');
});

final downloadsProvider = StreamProvider<List<DownloadItem>>((ref) async* {
  final boxAsync = await ref.watch(downloadsBoxProvider.future);
  
  yield boxAsync.values.toList();
  
  await for (final _ in boxAsync.watch()) {
    yield boxAsync.values.toList();
  }
});

final activeDownloadsProvider = Provider<AsyncValue<List<DownloadItem>>>((ref) {
  final downloads = ref.watch(downloadsProvider);
  return downloads.when(
    data: (list) => AsyncValue.data(
      list.where((d) => 
        d.status == DownloadStatus.downloading || 
        d.status == DownloadStatus.pending
      ).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final completedDownloadsProvider = Provider<AsyncValue<List<DownloadItem>>>((ref) {
  final downloads = ref.watch(downloadsProvider);
  return downloads.when(
    data: (list) => AsyncValue.data(
      list.where((d) => d.status == DownloadStatus.completed).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

class DownloadNotifier extends StateNotifier<AsyncValue<void>> {
  final DownloadService _service;
  final Box<DownloadItem> _box;

  DownloadNotifier(this._service, this._box) : super(const AsyncValue.data(null));

  Future<void> addDownload(DownloadItem item) async {
    state = const AsyncValue.loading();
    try {
      await _box.put(item.id, item);
      _startDownload(item);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> _startDownload(DownloadItem item) async {
    final downloadingItem = item.copyWith(status: DownloadStatus.downloading);
    await _box.put(item.id, downloadingItem);

    _service.setOnProgressUpdate((id, progress, received, total) {
      final updated = _box.get(id);
      if (updated != null) {
        _box.put(
          id,
          updated.copyWith(
            progress: progress,
            downloadedBytes: received,
            totalBytes: total,
          ),
        );
      }
    });

    final result = await _service.startDownload(downloadingItem);
    await _box.put(item.id, result);
  }

  Future<void> deleteDownload(String id) async {
    final item = _box.get(id);
    if (item != null) {
      await _service.deleteDownload(item);
      await _box.delete(id);
    }
  }

  Future<void> clearCompleted() async {
    final completed = _box.values
        .where((d) => d.status == DownloadStatus.completed)
        .toList();
    for (final item in completed) {
      await _service.deleteDownload(item);
      await _box.delete(item.id);
    }
  }
}

final downloadNotifierProvider = StateNotifierProvider<DownloadNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(downloadServiceProvider);
  final boxAsync = ref.watch(downloadsBoxProvider);
  
  return boxAsync.when(
    data: (box) => DownloadNotifier(service, box),
    loading: () => throw UnimplementedError('Box not loaded'),
    error: (e, _) => throw e,
  );
});
