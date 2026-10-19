import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_status_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'order_history_dimens.dart';
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
        OrderStatusLabel(
          status: status,
          iconSize: OrderHistoryDimens.iconL.w,
          spacing: OrderHistoryDimens.paddingS.w,
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: status.color,
            fontWeight: FontWeight.w500,
          ) ?? const TextStyle(),
        ),
        Text(
          '# ${shortOrderId(orderId)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}