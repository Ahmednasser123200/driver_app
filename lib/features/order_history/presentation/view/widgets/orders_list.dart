import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_constants.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'order_card.dart';

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
