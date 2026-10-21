import 'package:equatable/equatable.dart';

class PaginationEntity extends Equatable {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationEntity({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  @override
  List<Object?> get props => [
    page,
    pageSize,
    totalCount,
    totalPages,
    hasNextPage,
    hasPreviousPage,
  ];
}

class PaginatedEntity<T> extends Equatable {
  final List<T> items;
  final PaginationEntity pagination;

  const PaginatedEntity({required this.items, required this.pagination});

  @override
  List<Object?> get props => [items, pagination];
}
