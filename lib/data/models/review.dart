import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    required String contentId,
    required String contentType, // 'anime' or 'manga'
    required double rating,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int helpfulCount,
    @Default(false) bool containsSpoilers,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

@freezed
class ReviewVote with _$ReviewVote {
  const factory ReviewVote({
    required String reviewId,
    required String userId,
    required bool isHelpful,
    DateTime? createdAt,
  }) = _ReviewVote;

  factory ReviewVote.fromJson(Map<String, dynamic> json) =>
      _$ReviewVoteFromJson(json);
}
