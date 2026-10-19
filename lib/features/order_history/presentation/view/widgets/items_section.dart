import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../domain/entities/order_history_entities.dart';
import 'common/section_title.dart';
import 'order_item_card.dart';

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