import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'order_status_label.dart';

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
