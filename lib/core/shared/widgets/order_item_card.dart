import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class OrderItemCard extends StatelessWidget {
  const OrderItemCard({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
    this.productImage,
  });

  final String productName;
  final String price;
  final int quantity;
  final ImageProvider? productImage;

  @override
  Widget build(BuildContext context) {
    final displayProductName = productName.trim().isEmpty
        ? 'Unknown'
        : productName;
    final displayPrice = price.trim().isEmpty ? 'Unknown' : price;
    final displayQuantity = quantity <= 0 ? 0 : quantity;

    return Container(
      width: 365.w,
      height: 80.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.grey[200],
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: productImage == null
                  ? const Icon(Icons.image, size: 40)
                  : ClipOval(
                      child: Image(
                        image: productImage!,
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayProductName,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey[800]),
                ),
                SizedBox(height: 4.h),
                Text(
                  displayPrice,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'X$displayQuantity',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }
}
