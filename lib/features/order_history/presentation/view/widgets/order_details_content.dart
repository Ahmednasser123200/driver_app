import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
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
    final sectionGap = SizedBox(height: OrderHistoryDimens.paddingXxl.h);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(OrderHistoryDimens.paddingXl.w),
      children: [
        OrderDetailsHeader(status: details.status, orderId: details.orderId),
        sectionGap,
        PickupSection(store: details.store),
        sectionGap,
        UserSection(user: details.user),
        sectionGap,
        ItemsSection(items: details.items),
        SizedBox(height: OrderHistoryDimens.paddingM.h),
        SummarySection(details: details),
      ],
    );
  }
}
