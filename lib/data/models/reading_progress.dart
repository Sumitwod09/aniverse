import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'reading_progress.freezed.dart';
part 'reading_progress.g.dart';

@freezed
class ReadingProgress with _$ReadingProgress {
  const factory ReadingProgress({
    required String id,
    required String mangaId,
    required String mangaTitle,
    required String chapterId,
    required String chapterTitle,
    required int currentPage,
    required int totalPages,
    String? coverImage,
    DateTime? lastReadAt,
    @Default(false) bool isCompleted,
    @Default(0.0) double percentageRead,
  }) = _ReadingProgress;

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      _$ReadingProgressFromJson(json);
}

@HiveType(typeId: 2)
class ReadingProgressHive extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String mangaId;
  @HiveField(2)
  late String mangaTitle;
  @HiveField(3)
  late String chapterId;
  @HiveField(4)
  late String chapterTitle;
  @HiveField(5)
  late int currentPage;
  @HiveField(6)
  late int totalPages;
  @HiveField(7)
  String? coverImage;
  @HiveField(8)
  DateTime? lastReadAt;
  @HiveField(9, defaultValue: false)
  late bool isCompleted;
  @HiveField(10, defaultValue: 0.0)
  late double percentageRead;

  ReadingProgress toModel() => ReadingProgress(
        id: id,
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        chapterId: chapterId,
        chapterTitle: chapterTitle,
        currentPage: currentPage,
        totalPages: totalPages,
        coverImage: coverImage,
        lastReadAt: lastReadAt,
        isCompleted: isCompleted,
        percentageRead: percentageRead,
      );

  static ReadingProgressHive fromModel(ReadingProgress progress) =>
      ReadingProgressHive()
        ..id = progress.id
        ..mangaId = progress.mangaId
        ..mangaTitle = progress.mangaTitle
        ..chapterId = progress.chapterId
        ..chapterTitle = progress.chapterTitle
        ..currentPage = progress.currentPage
        ..totalPages = progress.totalPages
        ..coverImage = progress.coverImage
        ..lastReadAt = progress.lastReadAt
        ..isCompleted = progress.isCompleted
        ..percentageRead = progress.percentageRead;
}

@freezed
class Bookmark with _$Bookmark {
  const factory Bookmark({
    required String id,
    required String mangaId,
    required String mangaTitle,
    required String chapterId,
    required String chapterTitle,
    required int pageNumber,
    String? coverImage,
    DateTime? createdAt,
    String? note,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
}

@HiveType(typeId: 3)
class BookmarkHive extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String mangaId;
  @HiveField(2)
  late String mangaTitle;
  @HiveField(3)
  late String chapterId;
  @HiveField(4)
  late String chapterTitle;
  @HiveField(5)
  late int pageNumber;
  @HiveField(6)
  String? coverImage;
  @HiveField(7)
  DateTime? createdAt;
  @HiveField(8)
  String? note;

  Bookmark toModel() => Bookmark(
        id: id,
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        chapterId: chapterId,
        chapterTitle: chapterTitle,
        pageNumber: pageNumber,
        coverImage: coverImage,
        createdAt: createdAt,
        note: note,
      );

  static BookmarkHive fromModel(Bookmark bookmark) => BookmarkHive()
    ..id = bookmark.id
    ..mangaId = bookmark.mangaId
    ..mangaTitle = bookmark.mangaTitle
    ..chapterId = bookmark.chapterId
    ..chapterTitle = bookmark.chapterTitle
    ..pageNumber = bookmark.pageNumber
    ..coverImage = bookmark.coverImage
    ..createdAt = bookmark.createdAt
    ..note = bookmark.note;
}
