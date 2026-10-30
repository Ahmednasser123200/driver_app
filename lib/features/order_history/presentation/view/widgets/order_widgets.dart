import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_status_ui.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'common_widgets.dart';

class OrderHistoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const OrderHistoryAppBar({
    super.key,
    required this.title,
    this.showBack = true,
  });

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: showBack ? 0 : OrderHistoryDimens.paddingXl.w,
      leading: showBack ? const _BackButton() : null,
      title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new, size: OrderHistoryDimens.iconM.w),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}

class OrderStatusLabel extends StatelessWidget {
  const OrderStatusLabel({
    super.key,
    required this.status,
    required this.iconSize,
    required this.spacing,
    required this.textStyle,
  });

  final OrderStatus status;
  final double iconSize;
  final double spacing;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(status.icon, color: status.color, size: iconSize),
        SizedBox(width: spacing),
        Text(status.label(AppLocalizations.of(context)!), style: textStyle),
      ],
    );
  }
}

class OrderDetailsHeader extends StatelessWidget {
  const OrderDetailsHeader({
    super.key,
    required this.status,
    required this.orderId,
  });

  final OrderStatus status;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _HeaderStatus(status: status),
        Text(
          formatOrderId(orderId),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _HeaderStatus extends StatelessWidget {
  const _HeaderStatus({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: status.color,
      fontWeight: FontWeight.w500,
    );
    return OrderStatusLabel(
      status: status,
      iconSize: OrderHistoryDimens.iconL.w,
      spacing: OrderHistoryDimens.paddingS.w,
      textStyle: style,
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
          SizedBox(width: OrderHistoryDimens.paddingL.w),
          Expanded(
            child: _AddressText(name: name, address: address),
          ),
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
          child: Text(address, style: Theme.of(context).textTheme.titleSmall),
        ),
      ],
    );
  }
}

class ErrorMessageView extends StatelessWidget {
  const ErrorMessageView({super.key, required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CenteredScrollView(
      child: Padding(
        padding: EdgeInsets.all(OrderHistoryDimens.paddingXxxl.w),
        child: Text(
          mapAppFailureToMessage(failure, l10n),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
