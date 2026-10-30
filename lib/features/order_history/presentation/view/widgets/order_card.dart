import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import 'common_widgets.dart';
import 'order_widgets.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(OrderHistoryDimens.radiusM.r);
    return Padding(
      padding: EdgeInsets.only(bottom: OrderHistoryDimens.paddingXl.h),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: () => _openDetails(context),
          child: OrderCardBody(order: order),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      Routes.orderHistoryDetails,
      arguments: order.orderId,
    );
  }
}

class OrderCardBody extends StatelessWidget {
  const OrderCardBody({super.key, required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(OrderHistoryDimens.paddingL.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.flowerOrder,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: OrderHistoryDimens.paddingM.h),
          OrderDetailsHeader(status: order.status, orderId: order.orderId),
          SizedBox(height: OrderHistoryDimens.paddingL.h),
          OrderCardAddresses(order: order),
        ],
      ),
    );
  }
}

class OrderCardAddresses extends StatelessWidget {
  const OrderCardAddresses({super.key, required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledAddress(
          label: AppLocalizations.of(context)!.pickupAddress,
          name: order.store.name,
          address: order.store.address,
          imageUrl: order.store.imageUrl,
        ),
        SizedBox(height: OrderHistoryDimens.paddingL.h),
        _LabeledAddress(
          label: AppLocalizations.of(context)!.userAddress,
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
