import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'orders_stat_card_body.dart';

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
    return Material(
      color: AppColors.primary.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => onToggle(status),
        child: OrdersStatCardBody(status: status, count: count),
      ),
    );
  }
}