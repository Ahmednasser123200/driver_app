import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'config/dio/auth_interceptor.dart';
import 'config/di/di.dart';
import 'config/routing/app_routes.dart';
// import 'config/routing/routes.dart';
import 'core/themes/app_themes/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  configureDependencies();
  await getIt<AuthInterceptors>().setToken(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMWExNGU5Yi1mYTlkLTdiOWQtOWYyNi1iYTE5MzRjMWJlZTAiLCJlbWFpbCI6ImRyaXZlcjkyMzRAZXhhbXBsZS5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJEcml2ZXIiLCJleHAiOjE3OTI0MDk4MzYsImlzcyI6IkZsb3dlcnNBdXRoIiwiYXVkIjoiRmxvd2Vyc0FwcCJ9.lF9s4vqHi0uKWrmdT5obMYmwFoqSljXeErAKVIBqtSU',
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
          // initialRoute: Routes.initial,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          navigatorObservers: [AppRoutes.routeObserver],
        );
      },
    );
  }
}
