import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manga.dart';
import '../models/paginated_response.dart';
import '../services/mangadex_service.dart';

// Service Provider
final mangaDexServiceProvider = Provider<MangaDexService>((ref) {
  return MangaDexService();
});

// Popular Manga Provider
final popularMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getPopularManga(limit: 20);
});

// Latest Updates Provider
final latestMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getLatestUpdates(limit: 20);
});

// Manga Detail Provider
final mangaDetailProvider = FutureProvider.family<MangaDetail, String>((ref, mangaId) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getMangaDetail(mangaId);
});

// Manga Chapters Provider
final mangaChaptersProvider = FutureProvider.family<List<Chapter>, String>((ref, mangaId) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getMangaChapters(mangaId, limit: 100);
});

// Chapter Pages Provider
final chapterPagesProvider = FutureProvider.family<ChapterPages, String>((ref, chapterId) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getChapterPages(chapterId);
});

// Search Query Provider
final mangaSearchQueryProvider = StateProvider<String>((ref) => '');

// Search Results Provider
final mangaSearchResultsProvider = FutureProvider.family<List<Manga>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.watch(mangaDexServiceProvider);
  return service.searchManga(query);
});

// Manga Filters State
final mangaFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});
