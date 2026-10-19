import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';
import 'order_details_cards.dart';
import 'order_details_content.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
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

class OrderCardAddresses extends StatelessWidget {
  const OrderCardAddresses({super.key, required this.order});

  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: AppStrings.pickupAddress),
        SizedBox(height: 8.h),
        AddressCard(
          name: order.store.name,
          address: order.store.address,
          imageUrl: order.store.imageUrl,
        ),
        SizedBox(height: 12.h),
        const FieldLabel(text: AppStrings.userAddress),
        SizedBox(height: 8.h),
        AddressCard(
          name: order.user.name,
          address: order.user.address,
          imageUrl: order.user.imageUrl,
        ),
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
    );
  }
}