import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:driver_app/features/auth/presentation/apply/view/apply_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

class MockApplyCubit extends Mock implements ApplyCubit {}

void main() {
  late MockApplyCubit mockApplyCubit;

  setUp(() {
    mockApplyCubit = MockApplyCubit();
    when(() => mockApplyCubit.state).thenReturn(const BaseState(data: ApplyState()));
    when(() => mockApplyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockApplyCubit.uiEventStream).thenAnswer((_) => const Stream.empty());
    when(() => mockApplyCubit.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<ApplyCubit>()) {
      getIt.unregister<ApplyCubit>();
    }
    getIt.registerFactory<ApplyCubit>(() => mockApplyCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<ApplyCubit>()) {
      getIt.unregister<ApplyCubit>();
    }
  });

  testWidgets('ApplyView renders correctly and shows form content', (tester) async {
    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: ApplyView(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ApplyView), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
  });
}
