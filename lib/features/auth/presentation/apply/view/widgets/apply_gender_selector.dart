import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplyGenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String>? onGenderChanged;

  const ApplyGenderSelector({
    super.key,
    this.selectedGender,
    this.onGenderChanged,
  });

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
        SizedBox(width: 24.w),
        RadioGroup<String>(
          groupValue: selectedGender,
          onChanged: (val) {
            if (val != null) {
              onGenderChanged?.call(val);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onGenderChanged?.call('Female'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Radio<String>(
                      value: 'Female',
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      AppStrings.female,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onGenderChanged?.call('Male'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Radio<String>(
                      value: 'Male',
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      AppStrings.male,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}