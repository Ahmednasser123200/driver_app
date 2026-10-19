import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_empty.dart';
import 'orders_list.dart';

class OrdersListArea extends StatelessWidget {
  const OrdersListArea({super.key, required this.state});
  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    final orders = state.visibleOrders;
    final isLoading = state.ordersListState.isLoading;
    if (orders.isEmpty) return OrdersEmpty(isLoading: isLoading);
    return OrdersList(
      orders: orders,
      isLoadingMore: isLoading,
      loadMoreFailed: state.failure != null,
      onLoadMore: () =>
          context.read<OrdersCubit>().doIntent(LoadMoreOrdersEvent()),
    );
  }
}