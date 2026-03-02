import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';

@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    required int currentPage,
    required int lastPage,
    required int total,
    required bool hasNextPage,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['items']?['total'] as int? ?? json['total'] as int? ?? 0,
      hasNextPage: json['has_next_page'] as bool? ?? false,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final Pagination pagination;

  const PaginatedResponse({
    required this.data,
    required this.pagination,
  });
}
