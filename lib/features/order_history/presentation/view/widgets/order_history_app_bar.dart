import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import '../../../../../core/themes/app_colors/app_colors.dart';

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
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
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
