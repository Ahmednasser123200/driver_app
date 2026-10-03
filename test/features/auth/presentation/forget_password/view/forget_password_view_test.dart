import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/forget_password_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockForgetPasswordCubit extends Mock implements ForgetPasswordCubit {
  @override
  Future<void> close() async {}
}

void main() {
  late MockForgetPasswordCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(ForgetPasswordEvent(email: 'test@example.com'));
  });

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    // Setting up an initial state
    when(
      () => mockCubit.state,
    ).thenReturn(const ForgetPasswordState(forgotState: BaseState()));
    // Mock the streams and methods
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.uiEventStream).thenAnswer((_) => const Stream.empty());
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
          child: const ForgetPasswordView(),
        ),
      ),
    );
  }

  testWidgets('renders ForgetPasswordView correctly', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ForgetPasswordView), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets(
    'shows validation error when email is empty and prevents form submission',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the confirm button without entering an email
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);

      // Verify that cubit event wasn't dispatched
      verifyNever(() => mockCubit.doEvent(any()));
    },
  );

  testWidgets('submits email when form is valid', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter a valid email
    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.pumpAndSettle();

    // Tap the confirm button
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Verify cubit event is dispatched
    verify(
      () => mockCubit.doEvent(
        any(
          that: isA<ForgetPasswordEvent>().having(
            (e) => e.email,
            'email',
            'test@example.com',
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('shows loading indicator when cubit state is loading', (
    tester,
  ) async {
    // Create a new mock with loading state
    final loadingMockCubit = MockForgetPasswordCubit();
    when(() => loadingMockCubit.state).thenReturn(
      const ForgetPasswordState(forgotState: BaseState(isLoading: true)),
    );
    when(() => loadingMockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => loadingMockCubit.uiEventStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => loadingMockCubit.doEvent(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider.value(
            value: loadingMockCubit,
            child: const ForgetPasswordView(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
