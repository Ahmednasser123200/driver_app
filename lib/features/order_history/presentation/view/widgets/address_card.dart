import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'common/avatar_image.dart';
import 'common/info_card.dart';

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
          SizedBox(width: OrderHistoryDimens.paddingL.w),
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.grey.shade500),
        ),
        SizedBox(height: OrderHistoryDimens.paddingM.h),
        _AddressLine(address: address),
      ],
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: OrderHistoryDimens.iconS.w),
        SizedBox(width: OrderHistoryDimens.paddingS.w),
        Expanded(
          child: Text(
            address,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
