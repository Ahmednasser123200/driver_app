import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_intent.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:driver_app/features/auth/presentation/login/view/login_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

Widget createTestableWidget(Widget child) {
  return ScreenUtilPlusInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  late MockLoginCubit mockLoginCubit;

  setUpAll(() {
    registerFallbackValue(EmailChanged(''));
    registerFallbackValue(PasswordChanged(''));
    registerFallbackValue(RememberMeChanged(false));
    registerFallbackValue(TogglePasswordVisibility());
    registerFallbackValue(LoginSubmitted());
  });

  setUp(() async {
    await getIt.reset();
    mockLoginCubit = MockLoginCubit();

    when(() => mockLoginCubit.state).thenReturn(const LoginState());
    when(() => mockLoginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLoginCubit.uiEventStream).thenAnswer((_) => const Stream.empty());
    when(() => mockLoginCubit.handle(any())).thenAnswer((_) async {});

    getIt.registerFactory<LoginCubit>(() => mockLoginCubit);
  });

  group('LoginView Widget Tests', () {
    testWidgets('renders initial UI elements correctly', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginView()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('dispatches EmailChanged when email input changes', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginView()));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'driver@test.com');
      await tester.pumpAndSettle();

      verify(() => mockLoginCubit.handle(any(that: isA<EmailChanged>())))
          .called(greaterThanOrEqualTo(1));
    });

    testWidgets('dispatches PasswordChanged when password input changes', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginView()));
      await tester.pumpAndSettle();

      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      verify(() => mockLoginCubit.handle(any(that: isA<PasswordChanged>())))
          .called(greaterThanOrEqualTo(1));
    });

    testWidgets('dispatches TogglePasswordVisibility when visibility icon is tapped', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginView()));
      await tester.pumpAndSettle();

      final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      verify(() => mockLoginCubit.handle(any(that: isA<TogglePasswordVisibility>()))).called(1);
    });

    testWidgets('dispatches RememberMeChanged when checkbox is toggled', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginView()));
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      verify(() => mockLoginCubit.handle(any(that: isA<RememberMeChanged>()))).called(1);
    });

    testWidgets('dispatches LoginSubmitted when form is filled and button is pressed', (tester) async {
      when(() => mockLoginCubit.state).thenReturn(
        const LoginState(
          email: 'valid@email.com',
          password: 'Password123',
        ),
      );

      await tester.pumpWidget(createTestableWidget(const LoginView()));
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'valid@email.com');
      await tester.enterText(passwordField, 'Password123');
      await tester.pumpAndSettle();

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => mockLoginCubit.handle(any(that: isA<LoginSubmitted>()))).called(1);
    });
  });
}
