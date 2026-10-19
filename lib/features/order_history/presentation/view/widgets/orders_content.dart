import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';
import 'order_details_cards.dart';
import 'orders_list.dart';
import 'orders_stats_row.dart';

class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key, required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrdersStatsRow(
            data: state.ordersListState.data ?? const OrdersDataState(),
            selected: state.statusFilter,
            onToggle: (status) => context
                .read<OrdersCubit>()
                .doIntent(ToggleStatusFilterEvent(status)),
          ),
          SizedBox(height: 20.h),
          const SectionTitle(text: AppStrings.recentOrders),
          SizedBox(height: 12.h),
          Expanded(child: OrdersListArea(state: state)),
        ],
      ),
    );
  }
}

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
      onLoadMore: () =>
          context.read<OrdersCubit>().doIntent(LoadMoreOrdersEvent()),
    );
  }
}

class OrdersEmpty extends StatelessWidget {
  const OrdersEmpty({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text(AppStrings.noOrdersYet),
    );
  }
}