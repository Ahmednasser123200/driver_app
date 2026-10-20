import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_status_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'order_status_label.dart';

class OrderDetailsHeader extends StatelessWidget {
  const OrderDetailsHeader({
    super.key,
    required this.status,
    required this.orderId,
  });

  final OrderStatus status;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _HeaderStatus(status: status),
        Text(
          formatOrderId(orderId),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _HeaderStatus extends StatelessWidget {
  const _HeaderStatus({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: status.color,
      fontWeight: FontWeight.w500,
    );
    return OrderStatusLabel(
      status: status,
      iconSize: OrderHistoryDimens.iconL.w,
      spacing: OrderHistoryDimens.paddingS.w,
      textStyle: style,
    );
  }
}
