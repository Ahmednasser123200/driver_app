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
    this.width,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;
  final double? width;
  final double? height;

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

    return SizedBox(
      width: width ?? 343.w,
      height: height ?? 48.h,
      child: variant == ButtonVariant.outlined
          ? OutlinedButton(
              onPressed: _canPress ? onPressed : null,
              child: child,
            )
          : ElevatedButton(
              onPressed: _canPress ? onPressed : null,
              child: child,
            ),
    );
  }
}