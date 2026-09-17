import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'config/di/di.dart';
import 'config/routing/app_routes.dart';
import 'config/routing/routes.dart';
import 'core/constants/app_strings/app_strings.dart';
import 'core/themes/app_themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: Routes.initial,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}