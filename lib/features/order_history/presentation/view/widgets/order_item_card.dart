import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'common/info_card.dart';
import 'order_history_dimens.dart';

class OrderItemCard extends StatelessWidget {
  const OrderItemCard({super.key, required this.item});

  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageUrl: product.imageUrl),
          SizedBox(width: OrderHistoryDimens.paddingL.w),
          Expanded(child: _ProductText(product: product)),
          Text(
            'X${item.quantity}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductText extends StatelessWidget {
  const _ProductText({required this.product});

  final OrderProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.grey.shade500,
          ),
        ),
        SizedBox(height: OrderHistoryDimens.paddingM.h),
        Text(
          formatPrice(product.price, product.currency),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: OrderHistoryDimens.productImageSize.w,
      height: OrderHistoryDimens.productImageSize.w,
      decoration: BoxDecoration(
        color: AppColors.primary.shade50,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, error, stack) => const Icon(
          Icons.local_florist_outlined,
          color: AppColors.primary,
        ),
      ),
    );
  }
}