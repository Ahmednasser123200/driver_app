import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import 'address_card.dart';
import 'common/field_label.dart';

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