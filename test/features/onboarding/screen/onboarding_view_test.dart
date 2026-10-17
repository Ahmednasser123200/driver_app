import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/onboarding/screen/onboaring_view.dart';
import 'package:driver_app/features/onboarding/screen/widget/animation_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  void setPhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump();
  }

  Future<void> disposeScreen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('OnboardingScreen', () {
    testWidgets('renders the welcome message', (tester) async {
      setPhoneSurface(tester);
      await pumpScreen(tester);

      expect(find.text(AppStrings.welcomeToApp), findsOneWidget);

      await disposeScreen(tester);
    });

    testWidgets('renders the driver lottie animation', (tester) async {
      setPhoneSurface(tester);
      await pumpScreen(tester);

      expect(find.byType(DriverAnimation), findsOneWidget);
      expect(find.byType(Lottie), findsOneWidget);

      await disposeScreen(tester);
    });

    testWidgets('renders the login and apply now buttons', (tester) async {
      setPhoneSurface(tester);
      await pumpScreen(tester);

      expect(
        find.widgetWithText(ElevatedButton, AppStrings.login),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextButton, AppStrings.applyNow),
        findsOneWidget,
      );

      await disposeScreen(tester);
    });

    testWidgets('tapping login navigates to the login route', (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: Routes.onboarding,
          routes: {
            Routes.onboarding: (_) => const OnboardingScreen(),
            Routes.login: (_) => const _LoginStubScreen(),
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.login));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(_LoginStubScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      await disposeScreen(tester);
    });

    testWidgets('tapping apply now does not navigate', (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: Routes.onboarding,
          routes: {
            Routes.onboarding: (_) => const OnboardingScreen(),
            Routes.apply: (_) => const _ApplyStubScreen(),
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, AppStrings.applyNow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(_ApplyStubScreen), findsNothing);

      await disposeScreen(tester);
    });
  });

  group('DriverAnimation', () {
    testWidgets('renders a Lottie widget', (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DriverAnimation())),
      );
      await tester.pump();

      expect(find.byType(Lottie), findsOneWidget);

      await disposeScreen(tester);
    });
  });
}

class _LoginStubScreen extends StatelessWidget {
  const _LoginStubScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('login stub')));
  }
}

class _ApplyStubScreen extends StatelessWidget {
  const _ApplyStubScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('apply stub')));
  }
}
