import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../config/errors/app_failure.dart';
import '../../../../../config/localization/app_failure_message_mapper.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import 'common_widgets.dart';
import 'order_widgets.dart';

class PickupSection extends StatelessWidget {
  const PickupSection({super.key, required this.store});
  final OrderStoreEntity store;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(text: AppLocalizations.of(context)!.pickupAddress),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
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
        SectionTitle(text: AppLocalizations.of(context)!.userAddress),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
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
        SectionTitle(text: AppLocalizations.of(context)!.orderDetails),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
        if (items.isEmpty)
          Text(
            mapAppFailureToMessage(
              const NotFoundFailure(),
              AppLocalizations.of(context)!,
            ),
          )
        else
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(bottom: OrderHistoryDimens.paddingL.h),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SummaryRow(
          label: l10n.total,
          value: formatPrice(details.totalPrice, details.currency),
        ),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
        SummaryRow(
          label: l10n.paymentMethod,
          value: details.isCashOnDelivery
              ? l10n.cashOnDelivery
              : l10n.creditCard,
        ),
      ],
    );
  }
}
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.titleMedium),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

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
          _QuantityText(quantity: item.quantity),
        ],
      ),
    );
  }
}

class _QuantityText extends StatelessWidget {
  const _QuantityText({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatQuantity(quantity),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.primary,
      ),
    );
  }
}

class _ProductText extends StatelessWidget {
  const _ProductText({required this.product});

  final OrderProductEntity product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.grey.shade500),
        ),
        SizedBox(height: OrderHistoryDimens.paddingM.h),
        Text(
          formatPrice(product.price, product.currency),
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
