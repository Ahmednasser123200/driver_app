import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'config/dio/auth_interceptor.dart';
import 'config/di/di.dart';
import 'config/routing/app_routes.dart';
import 'config/routing/routes.dart';
import 'core/themes/app_themes/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  configureDependencies();
  await getIt<AuthInterceptors>().setToken(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMWExNTU2Yi05NTc4LTc0MTEtODcyOS02NGJmNmZiMjgwYzEiLCJlbWFpbCI6Ik1vaGFtZWRkcml2ZUBleGFtcGxlLmNvbSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IkRyaXZlciIsImV4cCI6MTc5MjQ0MDY5NCwiaXNzIjoiRmxvd2Vyc0F1dGgiLCJhdWQiOiJGbG93ZXJzQXBwIn0.KYf-cb49S7m5C8KtHmgkhAR5TnstPGChee6FP8nUiYk',
  );
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
          title: AppLocalizations.of(context)?.appName ?? 'Flowery rider',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          initialRoute: Routes.pickupLocation,
          onGenerateInitialRoutes: AppRoutes.onGenerateInitialRoutes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          navigatorObservers: [AppRoutes.routeObserver],
        );
      },
    );
  }
}
