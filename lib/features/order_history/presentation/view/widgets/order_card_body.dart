import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import 'order_card_addresses.dart';
import 'order_details_header.dart';

class OrderCardBody extends StatelessWidget {
  const OrderCardBody({super.key, required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.flowerOrder,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          OrderDetailsHeader(status: order.status, orderId: order.orderId),
          SizedBox(height: 12.h),
          OrderCardAddresses(order: order),
        ],
      ),
    );
  }
}