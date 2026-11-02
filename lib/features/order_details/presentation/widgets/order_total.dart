import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/themes/app_colors/app_colors.dart';

class OrderTotal extends StatelessWidget {
  const OrderTotal({
    super.key,
    required this.totalAmount,
    required this.totalLabel,
  });

  final String totalAmount;
  final String totalLabel;
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
            totalLabel,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            totalAmount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
