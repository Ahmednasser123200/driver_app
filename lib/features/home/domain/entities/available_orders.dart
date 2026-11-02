import 'package:driver_app/features/home/domain/entities/available_order.dart';
import 'package:driver_app/features/home/domain/entities/pagination.dart';
import 'package:equatable/equatable.dart';

class AvailableOrders extends Equatable {
  final List<AvailableOrder> items;
  final Pagination pagination;

  const AvailableOrders({required this.items, required this.pagination});

  @override
  String toString() {
    return 'AvailableOrders(items: $items, pagination: $pagination)';
  }

  @override
  List<Object?> get props => [items, pagination];
}
