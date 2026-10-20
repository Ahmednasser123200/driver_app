import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'order_card_body.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(OrderHistoryDimens.radiusM.r);
    return Padding(
      padding: EdgeInsets.only(bottom: OrderHistoryDimens.paddingXl.h),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: () => _openDetails(context),
          child: OrderCardBody(order: order),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      Routes.orderDetails,
      arguments: order.orderId,
    );
  }
}
