import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';

sealed class OrdersEvent {}

class LoadOrdersEvent extends OrdersEvent {}

class LoadMoreOrdersEvent extends OrdersEvent {}

class ToggleStatusFilterEvent extends OrdersEvent {
  final OrderStatus status;

  ToggleStatusFilterEvent(this.status);
}