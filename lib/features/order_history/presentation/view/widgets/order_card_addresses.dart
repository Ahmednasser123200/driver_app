import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
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
        _LabeledAddress(
          label: AppStrings.pickupAddress,
          name: order.store.name,
          address: order.store.address,
          imageUrl: order.store.imageUrl,
        ),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
        _LabeledAddress(
          label: AppStrings.userAddress,
          name: order.user.name,
          address: order.user.address,
          imageUrl: order.user.imageUrl,
        ),
      ],
    );
  }
}

class _LabeledAddress extends StatelessWidget {
  const _LabeledAddress({
    required this.label,
    required this.name,
    required this.address,
    required this.imageUrl,
  });

  final String label;
  final String name;
  final String address;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        SizedBox(height: OrderHistoryDimens.paddingM.h),
        AddressCard(name: name, address: address, imageUrl: imageUrl),
      ],
    );
  }
}
