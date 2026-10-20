import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  RouteFactory? onGenerateRoute,
  Map<String, WidgetBuilder>? routes,
}) async {
  await tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routes: routes ?? const <String, WidgetBuilder>{},
          onGenerateRoute: onGenerateRoute,
          home: widget,
        );
      },
    ),
  );
  await tester.pump();
}
