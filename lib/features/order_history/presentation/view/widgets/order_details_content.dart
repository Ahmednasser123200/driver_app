import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'items_section.dart';
import 'order_details_header.dart';
import 'pickup_section.dart';
import 'summary_section.dart';
import 'user_section.dart';

class OrderDetailsContent extends StatelessWidget {
  const OrderDetailsContent({super.key, required this.details});
  final OrderHistoryDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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