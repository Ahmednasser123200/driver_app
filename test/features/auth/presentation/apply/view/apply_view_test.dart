import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_event.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:driver_app/features/auth/presentation/apply/view/apply_view.dart';
import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_file_upload_field.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

class MockApplyCubit extends Mock implements ApplyCubit {}
class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('dummy.jpg'));
  });

  late MockApplyCubit mockApplyCubit;
  late MockImagePicker mockImagePicker;
  late StreamController<BaseState<ApplyState>> stateController;
  late StreamController<BaseUiEvent> eventController;

  setUp(() {
    mockApplyCubit = MockApplyCubit();
    mockImagePicker = MockImagePicker();
    stateController = StreamController<BaseState<ApplyState>>.broadcast();
    eventController = StreamController<BaseUiEvent>.broadcast();

    when(() => mockApplyCubit.state).thenReturn(const BaseState(data: ApplyState()));
    when(() => mockApplyCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockApplyCubit.uiEventStream).thenAnswer((_) => eventController.stream);
    when(() => mockApplyCubit.close()).thenAnswer((_) async {});

    when(() => mockApplyCubit.onFirstNameChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onSecondNameChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onEmailChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onPhoneChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onNationalIdChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onVehicleNumberChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onPasswordChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onConfirmPasswordChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onGenderChanged(any())).thenReturn(null);
    when(() => mockApplyCubit.onLicenseFilePicked(any())).thenReturn(null);
    when(() => mockApplyCubit.onIdImagePicked(any())).thenReturn(null);
    when(() => mockApplyCubit.submit()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
    eventController.close();
  });

  Widget buildTestWidget({ApplyCubit? cubit, ImagePicker? picker}) {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routes: {
            Routes.successApply: (context) => const Scaffold(body: Text('Success Screen')),
          },
          home: ApplyView(
            cubit: cubit ?? mockApplyCubit,
            imagePicker: picker ?? mockImagePicker,
          ),
        );
      },
    );
  }

  testWidgets('ApplyView renders form content and all essential fields', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ApplyView), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.text(AppStrings.continueLabel), findsOneWidget);
    expect(find.text(AppStrings.gender), findsOneWidget);
  });

  testWidgets('Tapping Continue with empty fields triggers validation and does not submit', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap continue button without entering data
    final continueButton = find.widgetWithText(CustomButton, AppStrings.continueLabel);
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify submit was not called because form is invalid
    verifyNever(() => mockApplyCubit.submit());
  });

  testWidgets('Cubit emitting ApplyGenderMissingEvent displays SnackBar error', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    eventController.add(const ApplyGenderMissingEvent());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.pleaseSelectGender), findsOneWidget);
  });

  testWidgets('Cubit emitting ApplyLicenseMissingEvent displays SnackBar error', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    eventController.add(const ApplyLicenseMissingEvent());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.pleaseUploadVehicleLicense), findsOneWidget);
  });

  testWidgets('Cubit emitting ApplyIdImageMissingEvent displays SnackBar error', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    eventController.add(const ApplyIdImageMissingEvent());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.pleaseUploadIdImage), findsOneWidget);
  });

  testWidgets('Cubit emitting ApplySuccessEvent navigates to successApply route', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    eventController.add(const ApplySuccessEvent());
    await tester.pumpAndSettle();

    expect(find.text('Success Screen'), findsOneWidget);
  });

  testWidgets('Tapping file upload field triggers image picker', (tester) async {
    when(() => mockImagePicker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => XFile('test/license.jpg'));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final uploadFields = find.byType(ApplyFileUploadField);
    expect(uploadFields, findsNWidgets(2));

    await tester.ensureVisible(uploadFields.first);
    await tester.tap(uploadFields.first);
    await tester.pumpAndSettle();

    verify(() => mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
  });
}
