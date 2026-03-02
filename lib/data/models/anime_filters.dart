import 'package:freezed_annotation/freezed_annotation.dart';

part 'anime_filters.freezed.dart';
part 'anime_filters.g.dart';

@freezed
class AnimeFilters with _$AnimeFilters {
  const factory AnimeFilters({
    List<String>? types,
    List<String>? statuses,
    List<String>? genres,
    int? year,
    String? season,
    String? rating,
    String? orderBy,
    String? sort,
  }) = _AnimeFilters;

  factory AnimeFilters.fromJson(Map<String, dynamic> json) =>
      _$AnimeFiltersFromJson(json);

  const AnimeFilters._();

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (types != null && types!.isNotEmpty) {
      params['type'] = types!.join(',');
    }
    if (statuses != null && statuses!.isNotEmpty) {
      params['status'] = statuses!.first;
    }
    if (genres != null && genres!.isNotEmpty) {
      params['genres'] = genres!.join(',');
    }
    if (year != null) {
      params['start_date'] = '$year-01-01';
      params['end_date'] = '$year-12-31';
    }
    if (season != null) {
      params['season'] = season?.toLowerCase();
    }
    if (rating != null) {
      params['rating'] = rating;
    }
    if (orderBy != null) {
      params['order_by'] = orderBy;
    }
    if (sort != null) {
      params['sort'] = sort;
    }
    return params;
  }
}
