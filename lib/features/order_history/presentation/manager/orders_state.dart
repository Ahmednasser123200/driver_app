
import 'package:equatable/equatable.dart';

import '../../../../config/base/base_state.dart';
import '../../../../config/errors/app_failure.dart';
import '../../domain/entities/order_history_entities.dart';
import '../../domain/entities/pagination_entities.dart';

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

  final AppFailure? failure;

  const OrdersState({
    this.ordersListState = const BaseState(),
    this.statusFilter,
    this.failure,
  });

  List<OrderHistoryEntity> get visibleOrders {
    final orders = ordersListState.data?.orders ?? const <OrderHistoryEntity>[];
    final filter = statusFilter;
    if (filter == null) return orders;
    return orders.where((order) => order.status == filter).toList();
  }

  OrdersState copyWith({
    BaseState<OrdersDataState>? ordersListState,
    AppFailure? failure,
  }) {
    return OrdersState(
      ordersListState: ordersListState ?? this.ordersListState,
      statusFilter: statusFilter,
      failure: failure,
    );
  }

  OrdersState withFilter(OrderStatus? filter) {
    return OrdersState(
      ordersListState: ordersListState,
      statusFilter: filter,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [ordersListState, statusFilter, failure];
}
