import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../../../core/constants/order_formatters.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'order_details_sections.dart';

class OrderDetailsContent extends StatelessWidget {
  const OrderDetailsContent({super.key, required this.details});

  final OrderHistoryDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        OrderDetailsHeader(status: details.status, orderId: details.orderId),
        SizedBox(height: 20.h),
        PickupSection(store: details.store),
        SizedBox(height: 20.h),
        UserSection(user: details.user),
        SizedBox(height: 20.h),
        ItemsSection(items: details.items),
        SizedBox(height: 8.h),
        SummarySection(details: details),
      ],
    );
  }
}

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
        _StatusLabel(status: status),
        Text(
          '# ${shortOrderId(orderId)}',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == OrderStatus.completed;
    final color = isCompleted ? Colors.green : AppColors.error;
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: color,
          size: 24.w,
        ),
        SizedBox(width: 4.w),
        Text(
          isCompleted
              ? AppStrings.completed
              : AppStrings.cancelled,
          style: TextStyle(
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}