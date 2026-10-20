import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
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
        SizedBox(height: OrderHistoryDimens.paddingL.h),
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: OrderHistoryDimens.paddingL.h),
            child: OrderItemCard(item: item),
          ),
      ],
    );
  }
}
