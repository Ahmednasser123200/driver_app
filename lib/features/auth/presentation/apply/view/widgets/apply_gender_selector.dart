import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplyGenderSelector extends StatelessWidget {
  final ValueNotifier<bool?> isFemaleNotifier;

  const ApplyGenderSelector({super.key, required this.isFemaleNotifier});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          AppStrings.gender,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
        ),
        SizedBox(width: 44.w),
        ValueListenableBuilder<bool?>(
          valueListenable: isFemaleNotifier,
          builder: (context, isFemale, child) {
            return RadioGroup<bool>(
              groupValue: isFemale,
              onChanged: (val) => isFemaleNotifier.value = val,
              child: Row(
                children: [
                  const Radio<bool>(value: true, activeColor: AppColors.primary),
                  Text(
                    AppStrings.female,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.black),
                  ),
                  SizedBox(width: 15.5.w),
                  const Radio<bool>(value: false, activeColor: AppColors.primary),
                  Text(
                    AppStrings.male,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}