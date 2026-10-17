
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/onboarding/screen/widget/animation_view.dart';
import 'package:flutter/material.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DriverAnimation(),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.welcomeToApp,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton( 
             onPressed: () {
                Navigator.pushNamed(context, Routes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.divider,
                minimumSize: const Size(double.infinity, 50),
              ),
               child: Text(AppStrings.login),
            ),
            SizedBox(height: 2),
            TextButton(
              onPressed: () {},
              
              style: TextButton.styleFrom(
                maximumSize: const Size(double.infinity,50),
              ),
              child: Text(AppStrings.applyNow),
            ),
          ],
        ),
      ),
    );
  }
}
