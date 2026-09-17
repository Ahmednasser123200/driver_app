import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../core/themes/app_colors/app_colors.dart';

enum ButtonVariant { filled, outlined }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;

  bool get _canPress => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == ButtonVariant.filled
                  ? AppColors.white
                  : AppColors.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                SizedBox(width: 8.w),
              ],
              Text(label),
            ],
          );

    if (variant == ButtonVariant.outlined) {
      return SizedBox(
        width: 343.w,
        height: 48.h,
        child: OutlinedButton(
          onPressed: _canPress ? onPressed : null,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: 343.w,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _canPress ? onPressed : null,
        child: child,
      ),
    );
  }
}
