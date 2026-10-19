import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'order_history_dimens.dart';
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
  Widget_build(BuildContext context) => build(context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(OrderHistoryDimens.paddingL.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: OrderHistoryDimens.paddingS.h),
          OrderStatusLabel(
            status: status,
            iconSize: OrderHistoryDimens.iconM.w,
            spacing: 6.w,
            textStyle: Theme.of(context).textTheme.titleSmall!,
          ),
        ],
      ),
    );
  }
}