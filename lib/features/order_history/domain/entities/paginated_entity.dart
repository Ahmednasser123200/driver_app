import 'package:equatable/equatable.dart';

import 'pagination_entity.dart';

class PaginatedEntity<T> extends Equatable {
  final List<T> items;
  final PaginationEntity pagination;

  const PaginatedEntity({required this.items, required this.pagination});

  @override
  List<Object?> get props => [items, pagination];
}
