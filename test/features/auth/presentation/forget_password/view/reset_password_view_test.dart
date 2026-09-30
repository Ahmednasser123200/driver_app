import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/reset_password_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockForgetPasswordCubit extends Mock implements ForgetPasswordCubit {}

void main() {
  late MockForgetPasswordCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(
      ResetPasswordEvent(email: '', newPassword: '', resetCode: ''),
    );
  });

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    // Setting up an initial state
    when(
      () => mockCubit.state,
    ).thenReturn(const ForgetPasswordState(resetstate: BaseState()));
    // Mock the streams and methods
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.uiEventStream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.doEvent(any())).thenAnswer((_) async {});

    // Setup GetIt
    getIt.allowReassignment = true;
    getIt.registerFactory<ForgetPasswordCubit>(() => mockCubit);
  });

  tearDown(() {
    getIt.reset();
  });

  Widget buildTestWidget() {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const ResetPasswordView(
          email: 'test@example.com',
          otpcode: '123456',
        ),
      ),
    );
  }

  testWidgets('renders ResetPasswordView correctly', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordView), findsOneWidget);
    // Two text form fields: New Password, Confirm Password
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets(
    'shows validation error when fields are empty and prevents form submission',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the update button without entering passwords
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Verify cubit event wasn't dispatched
      verifyNever(() => mockCubit.doEvent(any()));
    },
  );

  testWidgets('submits new password when form is valid', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);

    // Enter a valid password
    await tester.enterText(textFields.at(0), 'Password123!');
    await tester.enterText(textFields.at(1), 'Password123!');
    await tester.pumpAndSettle();

    // Tap the update button
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Verify cubit event is dispatched
    verify(
      () => mockCubit.doEvent(
        any(
          that: isA<ResetPasswordEvent>()
              .having((e) => e.email, 'email', 'test@example.com')
              .having((e) => e.resetCode, 'resetCode', '123456')
              .having((e) => e.newPassword, 'newPassword', 'Password123!'),
        ),
      ),
    ).called(1);
  });
}
