import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'order_widgets.dart';

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

class OrdersStatCard extends StatelessWidget {
  const OrdersStatCard({
    super.key,
    required this.status,
    required this.count,
    required this.selected,
    required this.onToggle,
  });
  final OrderStatus status;
  final int count;
  final OrderStatus? selected;
  final ValueChanged<OrderStatus> onToggle;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == status;
    final radius = BorderRadius.circular(OrderHistoryDimens.radiusM.r);
    return Material(
      color: AppColors.primary.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          width: OrderHistoryDimens.selectedBorderWidth,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => onToggle(status),
        child: OrdersStatCardBody(status: status, count: count),
      ),
    );
  }
}

class OrdersStatCardBody extends StatelessWidget {
  const OrdersStatCardBody({
    super.key,
    required this.status,
    required this.count,
  });

  final OrderStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.all(OrderHistoryDimens.paddingL.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: textTheme.bodyLarge),
          SizedBox(height: OrderHistoryDimens.paddingS.h),
          OrderStatusLabel(
            status: status,
            iconSize: OrderHistoryDimens.iconM.w,
            spacing: OrderHistoryDimens.statusSpacing.w,
            textStyle: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
