import 'package:driver_app/features/home/domain/entities/pagination.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_dto.g.dart';

@JsonSerializable()
class PaginationDto {
  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'totalCount')
  final int totalCount;

  @JsonKey(name: 'totalPages')
  final int totalPages;

  @JsonKey(name: 'hasNextPage')
  final bool hasNextPage;

  @JsonKey(name: 'hasPreviousPage')
  final bool hasPreviousPage;

  PaginationDto({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);

  Pagination toDomain() => Pagination(
    page: page,
    pageSize: pageSize,
    totalCount: totalCount,
    totalPages: totalPages,
    hasNextPage: hasNextPage,
    hasPreviousPage: hasPreviousPage,
  );
}
