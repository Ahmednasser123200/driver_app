import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DeliverySuccessView extends StatelessWidget {
  const DeliverySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 96.h, 24.w, 24.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const _SuccessMark(),
                      SizedBox(height: 30.h),
                      Text(
                        l10n.orderDeliveredSuccessTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.orderDeliveredSuccessDescription,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 42.h),
                      CustomButton(
                        label: l10n.done,
                        width: double.infinity,
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.home,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    final size = 136.w;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.75, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.shade50,
          ),
          child: Center(
            child: Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.shade100,
              ),
              child: Center(
                child: Container(
                  width: size * 0.56,
                  height: size * 0.56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.shade200,
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.38,
                      height: size * 0.38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.shade300,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 36.w,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
