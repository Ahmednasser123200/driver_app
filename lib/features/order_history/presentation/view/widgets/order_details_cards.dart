import 'package:driver_app/core/constants/app_images/app_images.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/order_formatters.dart';
import '../../../domain/entities/order_history_entities.dart';


class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Network photo, or the asset photo when the URL is missing or fails.
class AvatarImage extends StatelessWidget {
  const AvatarImage({super.key, required this.imageUrl, this.size = 48});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      AppImages.defaultAvatar,
      fit: BoxFit.cover,
    );
    final url = imageUrl;
    return ClipOval(
      child: SizedBox(
        width: size.w,
        height: size.w,
        child: (url == null || url.isEmpty)
            ? fallback
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => fallback,
        ),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.name,
    required this.address,
    required this.imageUrl,
  });

  final String name;
  final String address;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        children: [
          AvatarImage(imageUrl: imageUrl),
          SizedBox(width: 12.w),
          Expanded(child: _AddressText(name: name, address: address)),
        ],
      ),
    );
  }
}

class _AddressText extends StatelessWidget {
  const _AddressText({required this.name, required this.address});

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).hintColor,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16.w),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                address,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
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
          SizedBox(width: 12.w),
          Expanded(child: _ProductText(product: product)),
          Text(
            'X${item.quantity}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
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
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).hintColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          formatPrice(product.price, product.currency),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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
    final background = Theme.of(context).colorScheme.primaryContainer;
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
        const Icon(Icons.local_florist_outlined),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}