import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:pinput/pinput.dart';

abstract final class OtpPinTheme {
  static PinTheme themeDefaultPin(TextTheme textTheme) {
    return PinTheme(
      width: 40.w,
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.white60,
        borderRadius: BorderRadius.circular(8.r),
      ),
      textStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static PinTheme themeFocusedPin(TextTheme textTheme) {
    return PinTheme(
      width: 45.w,
      height: 55.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.white50,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.pinkBase.withValues(alpha: 0.2),
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      textStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.pinkBase,
      ),
    );
  }

  static PinTheme themeSubmittedPin(TextTheme textTheme) {
    return PinTheme(
      width: 40.w,
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.pinkBase,
        borderRadius: BorderRadius.circular(8.r),
      ),
      textStyle: textTheme.bodyLarge?.copyWith(
        color: AppColors.whiteBase,
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static PinTheme themeDisabledPin(TextTheme textTheme) {
    return PinTheme(
      width: 40.w,
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.white60,
        borderRadius: BorderRadius.circular(8.r),
      ),
      textStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.black.withValues(alpha: 0.54),
      ),
    );
  }

  static PinTheme themeErrorPin(TextTheme textTheme) {
    return PinTheme(
      width: 40.w,
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.whiteBase,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error),
      ),
      textStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
