import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/country_entity.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/vehicle_type_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_intent.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_ui_event.dart';
import 'package:driver_app/features/auth/presentation/apply/view/apply_view.dart';
import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_file_upload_field.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

class MockApplyCubit extends Mock implements ApplyCubit {}

void main() {
  const sampleCountry = CountryEntity(
    isoCode: 'EG',
    name: 'Egypt',
    phoneCode: '20',
    flag: '🇪🇬',
  );

  const sampleVehicle = VehicleTypeEntity(id: '1', name: 'Car');

  setUpAll(() {
    registerFallbackValue(const LoadInitialDataIntent());
    registerFallbackValue(const SubmitApplicationIntent());
    registerFallbackValue(const ChangeFirstNameIntent(''));
    registerFallbackValue(const ChangeSecondNameIntent(''));
    registerFallbackValue(const ChangeVehicleNumberIntent(''));
    registerFallbackValue(const ChangeEmailIntent(''));
    registerFallbackValue(const ChangePhoneIntent(''));
    registerFallbackValue(const ChangeNationalIdIntent(''));
    registerFallbackValue(const ChangePasswordIntent(''));
    registerFallbackValue(const ChangeConfirmPasswordIntent(''));
    registerFallbackValue(const ChangeGenderIntent(''));
    registerFallbackValue(const SelectCountryIntent(sampleCountry));
    registerFallbackValue(const SelectVehicleTypeIntent(sampleVehicle));
    registerFallbackValue(const PickLicenseImageIntent());
    registerFallbackValue(const PickIdImageIntent());
  });

  late MockApplyCubit mockApplyCubit;
  late StreamController<ApplyState> stateController;
  late StreamController<ApplyUiEvent> eventController;

  setUp(() {
    mockApplyCubit = MockApplyCubit();
    stateController = StreamController<ApplyState>.broadcast();
    eventController = StreamController<ApplyUiEvent>.broadcast();

    when(() => mockApplyCubit.state).thenReturn(
      const ApplyState(
        selectedCountry: sampleCountry,
        selectedVehicleType: sampleVehicle,
      ),
    );
    when(() => mockApplyCubit.stream).thenAnswer((_) => stateController.stream);
    when(
      () => mockApplyCubit.uiEventStream,
    ).thenAnswer((_) => eventController.stream);
    when(() => mockApplyCubit.close()).thenAnswer((_) => Future<void>.value());
    when(() => mockApplyCubit.processIntent(any())).thenReturn(null);

    if (getIt.isRegistered<ApplyCubit>()) {
      getIt.unregister<ApplyCubit>();
    }
    getIt.registerFactory<ApplyCubit>(() => mockApplyCubit);
  });

  tearDown(() {
    stateController.close();
    eventController.close();
    if (getIt.isRegistered<ApplyCubit>()) {
      getIt.unregister<ApplyCubit>();
    }
  });

  Widget buildTestWidget() {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routes: {
            Routes.successApply: (context) =>
                const Scaffold(body: Text('Success Screen')),
          },
          home: const ApplyView(),
        );
      },
    );
  }

  testWidgets('ApplyView renders form content and all essential fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ApplyView), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.text(AppStrings.apply), findsOneWidget);
    expect(find.text(AppStrings.continueLabel), findsOneWidget);
    expect(find.text(AppStrings.gender), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Tapping Continue with empty fields triggers validation and does not submit',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(
        CustomButton,
        AppStrings.continueLabel,
      );
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      verifyNever(
        () => mockApplyCubit.processIntent(
          any(that: isA<SubmitApplicationIntent>()),
        ),
      );

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Typing text field dispatches change intent', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final firstNameField = find.widgetWithText(
      TextFormField,
      AppStrings.enterFirstLegalName,
    );
    await tester.enterText(firstNameField, 'John');
    await tester.pumpAndSettle();

    verify(
      () =>
          mockApplyCubit.processIntent(any(that: isA<ChangeFirstNameIntent>())),
    ).called(greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Tapping upload field triggers image pick intents', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final uploadFields = find.byType(ApplyFileUploadField);
    expect(uploadFields, findsNWidgets(2));

    await tester.ensureVisible(uploadFields.first);
    await tester.tap(uploadFields.first);
    await tester.pumpAndSettle();

    verify(
      () => mockApplyCubit.processIntent(
        any(that: isA<PickLicenseImageIntent>()),
      ),
    ).called(1);

    await tester.ensureVisible(uploadFields.last);
    await tester.tap(uploadFields.last);
    await tester.pumpAndSettle();

    verify(
      () => mockApplyCubit.processIntent(any(that: isA<PickIdImageIntent>())),
    ).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Tapping gender triggers ChangeGenderIntent', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final femaleOption = find.text(AppStrings.female);
    await tester.ensureVisible(femaleOption);
    await tester.tap(femaleOption);
    await tester.pumpAndSettle();

    verify(
      () => mockApplyCubit.processIntent(any(that: isA<ChangeGenderIntent>())),
    ).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Cubit emitting ApplyGenderMissingEvent displays SnackBar error',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      eventController.add(const ApplyGenderMissingEvent());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pleaseSelectGender), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Cubit emitting ApplyLicenseMissingEvent displays SnackBar error',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      eventController.add(const ApplyLicenseMissingEvent());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pleaseUploadVehicleLicense), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Cubit emitting ApplyIdImageMissingEvent displays SnackBar error',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      eventController.add(const ApplyIdImageMissingEvent());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pleaseUploadIdImage), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Cubit emitting ApplyFailureEvent displays SnackBar with message',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      eventController.add(const ApplyFailureEvent(ServerFailure()));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Cubit emitting ApplySuccessEvent navigates to successApply route',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      eventController.add(const ApplySuccessEvent());
      await tester.pumpAndSettle();

      expect(find.text('Success Screen'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );
}
