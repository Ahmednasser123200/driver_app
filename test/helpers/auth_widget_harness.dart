import 'dart:io';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/core/themes/app_themes/app_theme.dart';
import 'package:driver_app/features/auth/domain/use_case/forget_password_user_case.dart';
import 'package:driver_app/features/auth/domain/use_case/reset_password_user_case.dart';
import 'package:driver_app/features/auth/domain/use_case/verify_otp_user_case.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mockito_dummies.dart';

bool _fontsLoaded = false;

/// Registers the real Roboto faces bundled with the Flutter SDK under the
/// default `Roboto` family.
///
/// Without this, `flutter test` falls back to its own fixed-width test font,
/// which renders every glyph at one em of advance. The auth screens then report
/// bogus `RenderFlex` overflows that never happen on a device, because the app
/// theme sets no `fontFamily` and so inherits the platform default.
///
/// Resolved from `FLUTTER_ROOT`, which the flutter tool exports to the test
/// process. If it is missing the helper is a no-op.
Future<void> loadAuthTestFonts() async {
  if (_fontsLoaded) return;

  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      r'D:\ali\sdks\flutter_3.44.9\flutter';

  final fontDir = Directory(
    '$flutterRoot${Platform.pathSeparator}bin${Platform.pathSeparator}'
    'cache${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
    'material_fonts',
  );
  if (!fontDir.existsSync()) return;

  final loader = FontLoader('Roboto');
  bool hasFonts = false;
  for (final face in const ['roboto-regular.ttf']) {
    final file = File('${fontDir.path}${Platform.pathSeparator}$face');
    if (!file.existsSync()) continue;

    final bytes = await file.readAsBytes();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    hasFonts = true;
  }

  if (hasFonts) {
    await loader.load();
  }

  _fontsLoaded = true;
}

/// Text rendered by the placeholder page used for every named route push, so a
/// test can assert that a `NavigateTo` event really reached the navigator.
const kRouteDestinationText = 'route-destination';

/// The design size the app is laid out against. Widget tests must use a
/// surface of the same size, otherwise the `Column`s inside the auth screens
/// overflow the default 800x600 test surface.
const kAuthDesignSize = Size(375, 812);

/// Wraps [screen] in the same scaffolding `DriverApp` provides: a
/// `ScreenUtilPlusInit` for `10.w`/`20.sp` calls, the app theme, and the
/// generated localisations.
///
/// `onGenerateRoute` is required because `BaseUiEventListener` calls
/// `Navigator.pushNamed` for every `NavigateTo` event, which throws when the
/// route table has no entry for that name. Every push is reported through
/// [onNavigate] and resolves to an inert page.
Future<void> pumpAuthScreen(
  WidgetTester tester,
  Widget screen, {
  void Function(String routeName)? onNavigate,
}) async {
  // await loadAuthTestFonts();

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = kAuthDesignSize;

  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  await tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: kAuthDesignSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: screen),
          onGenerateRoute: (settings) {
            onNavigate?.call(settings.name ?? '');
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(
                body: Center(child: Text(kRouteDestinationText)),
              ),
            );
          },
        );
      },
    ),
  );
}

/// Registers a `ForgetPasswordCubit` built from the supplied mocks and returns
/// it, so a test can assert on the state the screen actually rendered.
///
/// A singleton is used rather than a factory because the view resolves the
/// cubit through `getIt`; returning the instance keeps `resolve()` cheap and
/// guarantees the test and the widget share one state stream. Call
/// [resetAuthTestContainer] between tests because the owning `BlocProvider`
/// closes the cubit when the widget is disposed.
ForgetPasswordCubit registerForgetPasswordCubit({
  required ForgetPasswordUserCase forgetUserCase,
  required VerifyOtpUserCase verifyUserCase,
  required ResetPasswordUserCase resetUserCase,
}) {
  final cubit = ForgetPasswordCubit(
    forgetUserCase,
    verifyUserCase,
    resetUserCase,
  );
  getIt.registerSingleton<ForgetPasswordCubit>(cubit);
  return cubit;
}

/// Clears the global container and re-registers the generic response dummies.
/// Call from `setUp` of every widget test.
Future<void> resetAuthTestContainer() async {
  await getIt.reset();
  registerAuthDummies();
}

/// Types into the single text field of a form-based auth screen.
///
/// The screens build `CustomTextFormField` without keys, so the field is found
/// by the count of editable widgets rather than by a finder key.
Future<void> enterField(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextFormField), text);
  await tester.pump();
}
