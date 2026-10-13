import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'config/di/di.dart';
import 'config/routing/app_routes.dart';
import 'config/routing/routes.dart';
import 'core/services/token_storage_service.dart';
import 'core/themes/app_themes/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  configureDependencies();

  final tokenStorage = getIt<TokenStorageService>();
  final token = await tokenStorage.getAccessToken();
  final initialRoute = (token != null && token.isNotEmpty)
      ? Routes.home
      : Routes.login;

  runApp(DriverApp(initialRoute: initialRoute));
}

class DriverApp extends StatelessWidget {
  final String initialRoute;

  const DriverApp({
    super.key,
    this.initialRoute = Routes.login,
  });

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
          initialRoute: initialRoute,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}