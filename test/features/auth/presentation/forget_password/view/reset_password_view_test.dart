import 'dart:async';

import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/reset_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/auth_widget_harness.dart';

class MockForgetPasswordCubit extends Mock implements ForgetPasswordCubit {
  @override
  Future<void> close() async {}
}

void main() {
  const email = 'test@example.com';
  const resetToken = 'valid-token';
  const password = 'Password123!';

  late MockForgetPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> uiEventController;

  // The state a user reaches after a successful OTP verification.
  final verifiedState = ForgetPasswordState(
    email: email,
    otpState: BaseState<VerifyOtpEntity>(
      data: VerifyOtpEntity(
        resetToken: resetToken,
        expiresAtUtc: DateTime.utc(2026, 1, 1),
      ),
    ),
  );

  void stubState(ForgetPasswordState state) {
    when(() => mockCubit.state).thenReturn(state);
  }

  setUpAll(() {
    registerFallbackValue(
      ResetPasswordEvent(email: '', newPassword: '', resetCode: ''),
    );
  });

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    uiEventController = StreamController<BaseUiEvent>.broadcast();

    stubState(verifiedState);
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockCubit.uiEventStream,
    ).thenAnswer((_) => uiEventController.stream);
    when(
      () => mockCubit.doEvent(any()),
    ).thenAnswer((_) => Future<void>.value());
  });

  tearDown(() async {
    await uiEventController.close();
    await mockCubit.close();
  });

  Future<void> pumpView(WidgetTester tester) async {
    await pumpAuthScreen(tester, const ResetPasswordView(), cubit: mockCubit);
    await tester.pump();
  }

  Future<void> enterPasswords(
    WidgetTester tester, {
    required String newPassword,
    required String confirmation,
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), newPassword);
    await tester.enterText(fields.at(1), confirmation);
    await tester.pump();
  }

  Future<void> tapUpdate(WidgetTester tester) async {
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
  }

  // The validators return a ValidationError that the form field turns into a
  // localized message, so the test reads the message the field is actually
  // showing instead of hardcoding English text.
  String? errorTextOf(WidgetTester tester, int fieldIndex) {
    final field = find.byType(TextFormField).at(fieldIndex);
    return tester.state<FormFieldState<String>>(field).errorText;
  }

  void expectErrorVisible(WidgetTester tester, int fieldIndex) {
    final message = errorTextOf(tester, fieldIndex);
    expect(message, isNotNull);
    expect(find.text(message!), findsOneWidget);
  }

  testWidgets('renders both password fields and the update button', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.byType(ResetPasswordView), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('empty fields show both validation errors and send nothing', (
    tester,
  ) async {
    await pumpView(tester);

    await tapUpdate(tester);

    expectErrorVisible(tester, 0);
    expectErrorVisible(tester, 1);
    verifyNever(() => mockCubit.doEvent(any()));
  });

  testWidgets('mismatched passwords show an error and send nothing', (
    tester,
  ) async {
    await pumpView(tester);

    await enterPasswords(
      tester,
      newPassword: password,
      confirmation: 'Different123!',
    );
    await tapUpdate(tester);

    expect(errorTextOf(tester, 0), isNull);
    expectErrorVisible(tester, 1);
    verifyNever(() => mockCubit.doEvent(any()));
  });

  testWidgets('matching passwords send the email and reset token from state', (
    tester,
  ) async {
    await pumpView(tester);

    await enterPasswords(tester, newPassword: password, confirmation: password);
    await tapUpdate(tester);

    expect(errorTextOf(tester, 0), isNull);
    expect(errorTextOf(tester, 1), isNull);
    verify(
      () => mockCubit.doEvent(
        any(
          that: isA<ResetPasswordEvent>()
              .having((e) => e.email, 'email', email)
              .having((e) => e.resetCode, 'resetCode', resetToken)
              .having((e) => e.newPassword, 'newPassword', password),
        ),
      ),
    ).called(1);
  });

  testWidgets('cannot submit before the otp is verified', (tester) async {
    stubState(const ForgetPasswordState(email: email));

    await pumpView(tester);
    await enterPasswords(tester, newPassword: password, confirmation: password);
    await tapUpdate(tester);

    verifyNever(() => mockCubit.doEvent(any()));
  });

  testWidgets('cannot submit while the reset request is loading', (
    tester,
  ) async {
    stubState(
      ForgetPasswordState(
        email: email,
        otpState: verifiedState.otpState,
        resetState: const BaseState(isLoading: true),
      ),
    );

    await pumpView(tester);
    await enterPasswords(tester, newPassword: password, confirmation: password);
    await tapUpdate(tester);

    verifyNever(() => mockCubit.doEvent(any()));
  });
}
