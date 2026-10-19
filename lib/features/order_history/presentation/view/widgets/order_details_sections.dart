import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../../../core/constants/order_formatters.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'order_details_cards.dart';

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

class UserSection extends StatelessWidget {
  const UserSection({super.key, required this.user});

  final OrderUserEntity user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: AppStrings.userAddress),
        SizedBox(height: 12.h),
        AddressCard(
          name: user.name,
          address: user.address,
          imageUrl: user.imageUrl,
        ),
      ],
    );
  }
}

class ItemsSection extends StatelessWidget {
  const ItemsSection({super.key, required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: AppStrings.orderDetails),
        SizedBox(height: 12.h),
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: OrderItemCard(item: item),
          ),
      ],
    );
  }
}

class SummarySection extends StatelessWidget {
  const SummarySection({super.key, required this.details});

  final OrderHistoryDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryRow(
          label: AppStrings.total,
          value: formatPrice(details.totalPrice, details.currency),
        ),
        if (details.isCashOnDelivery) ...[
          SizedBox(height: 12.h),
          const SummaryRow(
            label: AppStrings.paymentMethod,
            value: AppStrings.cashOnDelivery,
          ),
        ],
      ],
    );
  }
}