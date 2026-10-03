import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/verification_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/widgets/custom_pin_widget.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';

class MockForgetPasswordCubit extends Mock implements ForgetPasswordCubit {
  @override
  Future<void> close() async {}
}

void main() {
  late MockForgetPasswordCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(VerifyOtpEvent(email: '', otpCode: ''));
  });

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    // Setting up an initial state
    when(
      () => mockCubit.state,
    ).thenReturn(const ForgetPasswordState(otpState: BaseState()));
    // Mock the streams and methods
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.uiEventStream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.startResendCooldown()).thenReturn(null);
    when(() => mockCubit.doEvent(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await mockCubit.close();
  });

  Widget buildTestWidget() {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider.value(
          value: mockCubit,
          child: VerificationView(email: 'test@example.com', cubit: mockCubit),
        ),
      ),
    );
  }

  testWidgets('renders VerificationView correctly', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(VerificationView), findsOneWidget);
    expect(find.byType(CustomPinWidget), findsOneWidget);
    expect(find.byType(Pinput), findsOneWidget);

    // verify startResendCooldown is called on build
    verify(() => mockCubit.startResendCooldown()).called(1);
  });

  testWidgets('submits otp when 6 digits are entered', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Trigger onCompleted directly
    tester.widget<Pinput>(find.byType(Pinput)).onCompleted?.call('123456');
    await tester.pumpAndSettle();

    // Verify cubit event is dispatched
    verify(
      () => mockCubit.doEvent(
        any(
          that: isA<VerifyOtpEvent>()
              .having((e) => e.email, 'email', 'test@example.com')
              .having((e) => e.otpCode, 'otpCode', '123456'),
        ),
      ),
    ).called(1);
  });

  testWidgets('does not submit otp when less than 6 digits are entered', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter only 3 digits using enterText, which doesn't trigger onCompleted but simulates input
    await tester.enterText(find.byType(Pinput), '123');
    await tester.pump();

    // Verify cubit event is NOT dispatched
    verifyNever(() => mockCubit.doEvent(any()));
  });
}
