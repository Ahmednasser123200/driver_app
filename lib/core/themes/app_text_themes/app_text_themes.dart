import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors/app_colors.dart';

abstract final class AppTextThemes {
  static TextTheme textTheme() {
    const base = TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 80,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 40,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 36,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 13,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
    );

    final scaled = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 80.sp),
      displayMedium: base.displayMedium?.copyWith(fontSize: 40.sp),
      displaySmall: base.displaySmall?.copyWith(fontSize: 36.sp),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 24.sp),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 20.sp),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 18.sp),
      titleLarge: base.titleLarge?.copyWith(fontSize: 18.sp),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16.sp),
      titleSmall: base.titleSmall?.copyWith(fontSize: 14.sp),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16.sp),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14.sp),
      bodySmall: base.bodySmall?.copyWith(fontSize: 13.sp),
      labelLarge: base.labelLarge?.copyWith(fontSize: 14.sp),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12.sp),
      labelSmall: base.labelSmall?.copyWith(fontSize: 10.sp),
    );

    return GoogleFonts.interTextTheme(scaled);
  }

  static TextStyle logoTheme() {
    return GoogleFonts.imFellEnglish(
      fontSize: 20.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.primary,
    );
  }
}
