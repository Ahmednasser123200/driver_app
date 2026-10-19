import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/entities/pagination_entities.dart';
import 'package:equatable/equatable.dart';

class OrdersDataState extends Equatable {
  final List<OrderHistoryEntity> orders;
  final PaginationEntity? pagination;
  final int completedCount;
  final int cancelledCount;

  const OrdersDataState({
    this.orders = const [],
    this.pagination,
    this.completedCount = 0,
    this.cancelledCount = 0,
  });

  int countFor(OrderStatus status) {
    return status == OrderStatus.completed ? completedCount : cancelledCount;
  }

  OrdersDataState copyWith({
    List<OrderHistoryEntity>? orders,
    PaginationEntity? pagination,
    int? completedCount,
    int? cancelledCount,
  }) {
    return OrdersDataState(
      orders: orders ?? this.orders,
      pagination: pagination ?? this.pagination,
      completedCount: completedCount ?? this.completedCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
    );
  }

  @override
  List<Object?> get props => [orders, pagination, completedCount, cancelledCount];
}

class OrdersState extends Equatable {
  final BaseState<OrdersDataState> ordersListState;
  final OrderStatus? statusFilter;

  const OrdersState({
    this.ordersListState = const BaseState(),
    this.statusFilter,
  });

  List<OrderHistoryEntity> get visibleOrders {
    final orders = ordersListState.data?.orders ?? const <OrderHistoryEntity>[];
    final filter = statusFilter;
    if (filter == null) return orders;
    return orders.where((order) => order.status == filter).toList();
  }

  OrdersState copyWith({BaseState<OrdersDataState>? ordersListState}) {
    return OrdersState(
      ordersListState: ordersListState ?? this.ordersListState,
      statusFilter: statusFilter,
    );
  }

  OrdersState withFilter(OrderStatus? filter) {
    return OrdersState(ordersListState: ordersListState, statusFilter: filter);
  }

  @override
  List<Object?> get props => [ordersListState, statusFilter];
}