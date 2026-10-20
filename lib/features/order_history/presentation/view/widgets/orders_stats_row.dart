import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'orders_stat_card.dart';

class OrdersStatsRow extends StatelessWidget {
  const OrdersStatsRow({
    super.key,
    required this.data,
    required this.selected,
    required this.onToggle,
  });
  final OrdersDataState data;
  final OrderStatus? selected;
  final ValueChanged<OrderStatus> onToggle;
  static const _statuses = [OrderStatus.cancelled, OrderStatus.completed];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final status in _statuses) ...[
          if (status != _statuses.first)
            SizedBox(width: OrderHistoryDimens.paddingXl.w),
          Expanded(
            child: OrdersStatCard(
              status: status,
              count: data.countFor(status),
              selected: selected,
              onToggle: onToggle,
            ),
          ),
        ],
      ],
    );
  }
}
