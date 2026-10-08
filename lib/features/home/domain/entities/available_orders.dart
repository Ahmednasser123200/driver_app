import 'package:driver_app/features/home/domain/entities/available_order.dart';
import 'package:driver_app/features/home/domain/entities/pagination.dart';

class AvailableOrders {
  final List<AvailableOrder> items;
  final Pagination pagination;

  const AvailableOrders({
    required this.items,
    required this.pagination,
  });

  @override
  String toString() {
    return 'AvailableOrders(items: $items, pagination: $pagination)';
  }
}