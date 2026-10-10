import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/themes/app_colors/app_colors.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.method,
  });

  final String title;
  final String method;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            method,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey[600]),
          ),
        ],
      ),
    );
  }
}
