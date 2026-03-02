import 'package:hive_flutter/hive_flutter.dart';
import '../models/reading_progress.dart';

class ReadingProgressService {
  late Box<ReadingProgressHive> _progressBox;
  late Box<BookmarkHive> _bookmarkBox;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ReadingProgressHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BookmarkHiveAdapter());
    }
    _progressBox = await Hive.openBox<ReadingProgressHive>('reading_progress');
    _bookmarkBox = await Hive.openBox<BookmarkHive>('bookmarks');
  }

  // Reading Progress
  Future<void> saveProgress(ReadingProgress progress) async {
    final hiveModel = ReadingProgressHive.fromModel(progress);
    await _progressBox.put(progress.id, hiveModel);
  }

  Future<ReadingProgress?> getProgress(String mangaId) async {
    final hiveModel = _progressBox.get(mangaId);
    return hiveModel?.toModel();
  }

  List<ReadingProgress> getAllProgress() {
    return _progressBox.values.map((h) => h.toModel()).toList();
  }

  List<ReadingProgress> getRecentProgress({int limit = 20}) {
    final progress = _progressBox.values.map((h) => h.toModel()).toList();
    progress.sort((a, b) => 
      (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)));
    return progress.take(limit).toList();
  }

  List<ReadingProgress> getContinueReading() {
    return _progressBox.values
        .map((h) => h.toModel())
        .where((p) => !p.isCompleted && p.percentageRead < 1.0)
        .toList();
  }

  Future<void> deleteProgress(String mangaId) async {
    await _progressBox.delete(mangaId);
  }

  Future<void> clearAllProgress() async {
    await _progressBox.clear();
  }

  // Bookmarks
  Future<void> addBookmark(Bookmark bookmark) async {
    final hiveModel = BookmarkHive.fromModel(bookmark);
    await _bookmarkBox.put(bookmark.id, hiveModel);
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _bookmarkBox.delete(bookmarkId);
  }

  Bookmark? getBookmark(String bookmarkId) {
    return _bookmarkBox.get(bookmarkId)?.toModel();
  }

  List<Bookmark> getAllBookmarks() {
    return _bookmarkBox.values.map((h) => h.toModel()).toList();
  }

  List<Bookmark> getBookmarksForManga(String mangaId) {
    return _bookmarkBox.values
        .map((h) => h.toModel())
        .where((b) => b.mangaId == mangaId)
        .toList();
  }

  Future<void> clearAllBookmarks() async {
    await _bookmarkBox.clear();
  }
}
