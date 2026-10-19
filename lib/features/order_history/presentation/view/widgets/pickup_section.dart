import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'address_card.dart';
import 'common/section_title.dart';

class PickupSection extends StatelessWidget {
  const PickupSection({super.key, required this.store});
  final OrderStoreEntity store;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: AppStrings.pickupAddress),
        SizedBox(height: 12.h),
        AddressCard(
          name: store.name,
          address: store.address,
          imageUrl: store.imageUrl,
        ),
      ],
    );
  }
}