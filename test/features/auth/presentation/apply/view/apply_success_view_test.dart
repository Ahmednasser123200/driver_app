import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/features/auth/presentation/apply/view/apply_success_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  Widget buildTestWidget() {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          navigatorObservers: [mockObserver],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routes: {
            Routes.login: (context) => const Scaffold(body: Text('Login Screen')),
          },
          home: const ApplySuccessView(),
        );
      },
    );
  }

  testWidgets('renders ApplySuccessView with all elements', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ApplySuccessView), findsOneWidget);
    expect(find.text(AppStrings.applicationSubmittedTitle), findsOneWidget);
    expect(find.text(AppStrings.applicationSubmittedBody), findsOneWidget);
    expect(find.text(AppStrings.login), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
  });

  testWidgets('tapping login button navigates to login route', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
