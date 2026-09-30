import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/verification_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/widgets/custom_pin_widget.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';

class MockForgetPasswordCubit extends Mock implements ForgetPasswordCubit {}

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
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.startResendCooldown()).thenReturn(null);
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
        home: const VerificationView(email: 'test@example.com'),
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

    // Enter a 6 digit code
    await tester.enterText(find.byType(Pinput), '123456');
    // wait for pinput to trigger onCompleted
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
}
