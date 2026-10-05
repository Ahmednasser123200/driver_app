import 'dart:async';

import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/verification_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/widgets/custom_pin_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';

import '../../../../../helpers/auth_widget_harness.dart';

class MockForgetPasswordCubit extends Mock implements ForgetPasswordCubit {
  @override
  Future<void> close() async {}
}

void main() {
  const email = 'test@example.com';

  late MockForgetPasswordCubit mockCubit;
  late StreamController<ForgetPasswordState> stateController;
  late StreamController<BaseUiEvent> uiEventController;

  void stubState(ForgetPasswordState state) {
    when(() => mockCubit.state).thenReturn(state);
  }

  setUpAll(() {
    registerFallbackValue(VerifyOtpEvent(email: '', otpCode: ''));
  });

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    stateController = StreamController<ForgetPasswordState>.broadcast();
    uiEventController = StreamController<BaseUiEvent>.broadcast();

    stubState(const ForgetPasswordState(email: email));
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(
      () => mockCubit.uiEventStream,
    ).thenAnswer((_) => uiEventController.stream);
    when(
      () => mockCubit.doEvent(any()),
    ).thenAnswer((_) => Future<void>.value());
  });

  tearDown(() async {
    await stateController.close();
    await uiEventController.close();
    await mockCubit.close();
  });

  Future<void> pumpView(WidgetTester tester) async {
    await pumpAuthScreen(tester, const VerificationView(), cubit: mockCubit);
    await tester.pump();
  }

  testWidgets('renders the pin input and the resend link', (tester) async {
    await pumpView(tester);

    expect(find.byType(VerificationView), findsOneWidget);
    expect(find.byType(CustomPinWidget), findsOneWidget);
    expect(find.byType(Pinput), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_outlined), findsNothing);
    verifyNever(() => mockCubit.doEvent(any()));
  });

  testWidgets('submits the otp when 6 digits are typed', (tester) async {
    await pumpView(tester);

    await tester.enterText(find.byType(Pinput), '123456');
    await tester.pump();

    verify(
      () => mockCubit.doEvent(
        any(
          that: isA<VerifyOtpEvent>()
              .having((e) => e.email, 'email', email)
              .having((e) => e.otpCode, 'otpCode', '123456'),
        ),
      ),
    ).called(1);
  });

  testWidgets('does not submit when fewer than 6 digits are typed', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.enterText(find.byType(Pinput), '123');
    await tester.pump();

    verifyNever(() => mockCubit.doEvent(any()));
  });

  testWidgets('shows the error indicator when the otp is rejected', (
    tester,
  ) async {
    stubState(
      const ForgetPasswordState(
        email: email,
        otpState: BaseState<VerifyOtpEntity>(failure: BadRequestFailure()),
      ),
    );

    await pumpView(tester);

    expect(find.byIcon(Icons.error_outline_outlined), findsOneWidget);
  });

  testWidgets('the resend link sends a ResendOtpEvent for the email', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    verify(
      () => mockCubit.doEvent(
        any(that: isA<ResendOtpEvent>().having((e) => e.email, 'email', email)),
      ),
    ).called(1);
  });

  testWidgets(
    'shows the live countdown instead of the link while cooling down',
    (tester) async {
      stubState(
        const ForgetPasswordState(email: email, resendSecondsRemaining: 30),
      );

      await pumpView(tester);

      expect(find.byType(TextButton), findsNothing);
      expect(find.textContaining('30'), findsOneWidget);

      const next = ForgetPasswordState(
        email: email,
        resendSecondsRemaining: 29,
      );
      stubState(next);
      stateController.add(next);
      // The first pump delivers the stream event (which schedules a rebuild);
      // the second pump actually builds the frame.
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('29'), findsOneWidget);
      expect(find.textContaining('30'), findsNothing);
    },
  );

  testWidgets('ClearOtpField empties the pin input', (tester) async {
    await pumpView(tester);

    await tester.enterText(find.byType(Pinput), '12');
    await tester.pump();
    expect(tester.widget<Pinput>(find.byType(Pinput)).controller!.text, '12');

    uiEventController.add(const ClearOtpField());
    await tester.pump();

    expect(
      tester.widget<Pinput>(find.byType(Pinput)).controller!.text,
      isEmpty,
    );
  });
}
