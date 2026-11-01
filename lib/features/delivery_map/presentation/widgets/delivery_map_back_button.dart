import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DeliveryMapBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const DeliveryMapBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.white,
              size: 26.sp,
            ),
          ),
        ),
      ),
    );
  }
}
