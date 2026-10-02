import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_images/app_images.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplySuccessView extends StatelessWidget {
  const ApplySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              AppImages.bottomGraphic,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Spacer(flex: 3),
                  Image.asset(
                    AppImages.checkCircle,
                    width: 96.w,
                    height: 96.w,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    AppStrings.applicationSubmittedTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.applicationSubmittedBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const Spacer(flex: 4),
                  CustomButton(
                    label: AppStrings.login,
                    width: double.infinity,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.login,
                          (route) => false,
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}