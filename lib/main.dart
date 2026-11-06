import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'config/di/di.dart';
import 'config/dio/auth_interceptor.dart';
import 'config/routing/app_routes.dart';
import 'config/routing/routes.dart';
import 'core/constants/api_strings/api_strings.dart';
import 'core/themes/app_themes/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  configureDependencies();

  final envToken = dotenv.env['ACCESS_TOKEN'];
  if (envToken != null && envToken.isNotEmpty) {
    await getIt<AuthInterceptors>().setToken(envToken);
  }

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
          initialRoute: Routes.orderDetails,
          onGenerateInitialRoutes: (initialRoute) => [
            AppRoutes.onGenerateRoute(
              RouteSettings(
                name: initialRoute,
                arguments: ApiStrings.defaultOrderId,
              ),
            ),
          ],
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
