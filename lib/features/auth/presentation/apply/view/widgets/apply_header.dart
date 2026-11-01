import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplyHeader extends StatelessWidget {
  const ApplyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.welcome,
          style: theme.textTheme.titleLarge?.copyWith(color: AppColors.black),
        ),
        SizedBox(height: 4.h),
        Text(
          AppStrings.deliveryManJoinTeam,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}
