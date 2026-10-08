import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/themes/app_colors/app_colors.dart';

class OrderStatusHeader extends StatelessWidget {
  const OrderStatusHeader({
    super.key,
    required this.status,
    required this.orderId,
    required this.date,
  });

  final String status;
  final String orderId;
  final String date;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 365.w,
      decoration: BoxDecoration(
        color: AppColors.primary[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'status: $status',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 18.0.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Order ID: $orderId',
            style: TextStyle(fontSize: 16.0.sp, color: AppColors.black),
          ),
          const SizedBox(height: 8.0),
          Text(
            date,
            style: TextStyle(fontSize: 16.0.sp, color: AppColors.grey[600]),
          ),
        ],
      ),
    );
  }
}
