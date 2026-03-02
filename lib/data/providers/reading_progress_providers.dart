import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_progress.dart';
import '../services/reading_progress_service.dart';

// Service Provider
final readingProgressServiceProvider = Provider<ReadingProgressService>((ref) {
  final service = ReadingProgressService();
  service.init();
  return service;
});

// Reading Progress Providers
final readingProgressProvider = StreamProvider<List<ReadingProgress>>((ref) async* {
  final service = ref.watch(readingProgressServiceProvider);
  
  // Initial load
  yield service.getAllProgress();
  
  // Watch for changes
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield service.getAllProgress();
  }
});

final continueReadingProvider = Provider<List<ReadingProgress>>((ref) {
  final progressAsync = ref.watch(readingProgressProvider);
  return progressAsync.when(
    data: (progress) => progress.where((p) => !p.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final recentReadingProvider = Provider<List<ReadingProgress>>((ref) {
  final progressAsync = ref.watch(readingProgressProvider);
  return progressAsync.when(
    data: (progress) {
      final sorted = progress.toList()
        ..sort((a, b) => 
          (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)));
      return sorted.take(20).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Bookmark Providers
final bookmarksProvider = StreamProvider<List<Bookmark>>((ref) async* {
  final service = ref.watch(readingProgressServiceProvider);
  
  yield service.getAllBookmarks();
  
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield service.getAllBookmarks();
  }
});

// Actions
class ReadingProgressNotifier extends StateNotifier<void> {
  final ReadingProgressService _service;

  ReadingProgressNotifier(this._service) : super(null);

  Future<void> saveProgress(ReadingProgress progress) async {
    await _service.saveProgress(progress);
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    await _service.addBookmark(bookmark);
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _service.removeBookmark(bookmarkId);
  }

  Future<void> deleteProgress(String mangaId) async {
    await _service.deleteProgress(mangaId);
  }
}

final readingProgressNotifierProvider = StateNotifierProvider<ReadingProgressNotifier, void>((ref) {
  final service = ref.watch(readingProgressServiceProvider);
  return ReadingProgressNotifier(service);
});
