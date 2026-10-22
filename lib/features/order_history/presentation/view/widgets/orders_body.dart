import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_constants.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'common_widgets.dart';
import 'order_card.dart';
import 'order_widgets.dart';
import 'orders_stats.dart';

class OrdersBody extends StatelessWidget {
  const OrdersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<OrdersCubit>().doIntent(LoadOrdersEvent()),
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) => OrdersStateView(state: state),
      ),
    );
  }
}

class OrdersStateView extends StatelessWidget {
  const OrdersStateView({super.key, required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    if (state.ordersListState.data != null) return OrdersContent(state: state);
    final failure = state.failure;
    if (failure != null) return ErrorMessageView(failure: failure);
    return const Center(child: CircularProgressIndicator());
  }
}

class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key, required this.state});
  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(OrderHistoryDimens.paddingXl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrdersStatsRow(
            data: state.ordersListState.data ?? const OrdersDataState(),
            selected: state.statusFilter,
            onToggle: (status) => _toggleFilter(context, status),
          ),
          SizedBox(height: OrderHistoryDimens.paddingXxl.h),
          const SectionTitle(text: AppStrings.recentOrders),
          SizedBox(height: OrderHistoryDimens.paddingL.h),
          Expanded(child: OrdersListArea(state: state)),
        ],
      ),
    );
  }

  void _toggleFilter(BuildContext context, OrderStatus status) {
    context.read<OrdersCubit>().doIntent(ToggleStatusFilterEvent(status));
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
      loadMoreFailed: state.failure != null,
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
    return CenteredScrollView(
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text(AppStrings.noOrdersYet),
    );
  }
}

class OrdersList extends StatelessWidget {
  const OrdersList({
    super.key,
    required this.orders,
    required this.isLoadingMore,
    required this.loadMoreFailed,
    required this.onLoadMore,
  });

  final List<OrderHistoryEntity> orders;
  final bool isLoadingMore;

  /// After a failed request, load-more is retried only by a new swipe up at the
  /// end of the list (once per gesture), not on every scroll tick.
  final bool loadMoreFailed;
  final VoidCallback onLoadMore;

  bool _shouldLoadMore(ScrollNotification notification) {
    final metrics = notification.metrics;
    final nearEnd = metrics.pixels >=
        metrics.maxScrollExtent - OrderHistoryConstants.loadMoreThreshold;
    if (!nearEnd) return false;
    return !loadMoreFailed || notification is ScrollEndNotification;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_shouldLoadMore(notification)) onLoadMore();
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: orders.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) return const _LoadMoreIndicator();
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: OrderHistoryDimens.paddingXl.h),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
