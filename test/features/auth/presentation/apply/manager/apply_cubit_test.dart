import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/add_application_use_case.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_event.dart';

class MockAddApplicationUseCase extends Mock implements AddApplicationUseCase {}

class FakeApplicationEntity extends Fake implements ApplicationEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeApplicationEntity());
  });

  late MockAddApplicationUseCase mockAddApplicationUseCase;
  late ApplyCubit applyCubit;

  setUp(() {
    mockAddApplicationUseCase = MockAddApplicationUseCase();
    applyCubit = ApplyCubit(mockAddApplicationUseCase);
  });

  tearDown(() {
    applyCubit.close();
  });

  group('ApplyCubit', () {
    test('initial state is correct', () {
      expect(applyCubit.state.data, const ApplyState());
      expect(applyCubit.state.isLoading, false);
    });

    blocTest<ApplyCubit, BaseState<ApplyState>>(
      'emits updated state when all field values change',
      build: () => applyCubit,
      act: (cubit) {
        cubit.onCountryChanged('+20');
        cubit.onFirstNameChanged('Jane');
        cubit.onSecondNameChanged('Doe');
        cubit.onVehicleTypeChanged(VehicleType.motorcycle);
        cubit.onVehicleNumberChanged('123 XYZ');
        cubit.onEmailChanged('jane@example.com');
        cubit.onPhoneChanged('01234567890');
        cubit.onNationalIdChanged('12345678901234');
        cubit.onPasswordChanged('Secret123');
        cubit.onConfirmPasswordChanged('Secret123');
        cubit.onGenderChanged('Female');
        cubit.onLicenseFilePicked(File('lic.jpg'));
        cubit.onIdImagePicked(File('id.jpg'));
      },
      verify: (cubit) {
        final data = cubit.state.data!;
        expect(data.countryCode, '+20');
        expect(data.firstName, 'Jane');
        expect(data.secondName, 'Doe');
        expect(data.vehicleType, VehicleType.motorcycle);
        expect(data.vehicleNumber, '123 XYZ');
        expect(data.email, 'jane@example.com');
        expect(data.phoneNumber, '01234567890');
        expect(data.nationalId, '12345678901234');
        expect(data.password, 'Secret123');
        expect(data.confirmPassword, 'Secret123');
        expect(data.gender, 'Female');
        expect(data.vehicleLicenceFile?.path, 'lic.jpg');
        expect(data.idImage?.path, 'id.jpg');
      },
    );

    test('emits ApplyGenderMissingEvent and aborts submit when gender is null', () async {
      expectLater(
        applyCubit.uiEventStream,
        emits(isA<ApplyGenderMissingEvent>()),
      );

      await applyCubit.submit();

      verifyNever(() => mockAddApplicationUseCase.execute(any()));
    });

    test('emits ApplyLicenseMissingEvent and aborts submit when vehicleLicenceFile is null', () async {
      applyCubit.onGenderChanged('Male');

      expectLater(
        applyCubit.uiEventStream,
        emits(isA<ApplyLicenseMissingEvent>()),
      );

      await applyCubit.submit();

      verifyNever(() => mockAddApplicationUseCase.execute(any()));
    });

    test('emits ApplyIdImageMissingEvent and aborts submit when idImage is null', () async {
      applyCubit.onGenderChanged('Male');
      applyCubit.onLicenseFilePicked(File('license.jpg'));

      expectLater(
        applyCubit.uiEventStream,
        emits(isA<ApplyIdImageMissingEvent>()),
      );

      await applyCubit.submit();

      verifyNever(() => mockAddApplicationUseCase.execute(any()));
    });

    blocTest<ApplyCubit, BaseState<ApplyState>>(
      'emits loading true, calls usecase, and emits success on successful submit',
      build: () {
        when(() => mockAddApplicationUseCase.execute(any()))
            .thenAnswer((_) async => const Success(null));
        return applyCubit;
      },
      seed: () => BaseState(
        data: ApplyState(
          gender: 'Female',
          vehicleLicenceFile: File('license.jpg'),
          idImage: File('id.jpg'),
        ),
      ),
      act: (cubit) async {
        expectLater(
          cubit.uiEventStream,
          emits(isA<ApplySuccessEvent>()),
        );
        await cubit.submit();
      },
      expect: () => [
        isA<BaseState<ApplyState>>().having((s) => s.isLoading, 'isLoading', true),
        isA<BaseState<ApplyState>>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (cubit) {
        verify(() => mockAddApplicationUseCase.execute(any())).called(1);
      },
    );

    blocTest<ApplyCubit, BaseState<ApplyState>>(
      'emits loading true, calls usecase, and handles failure response',
      build: () {
        when(() => mockAddApplicationUseCase.execute(any()))
            .thenAnswer((_) async => const Error(ServerFailure()));
        return applyCubit;
      },
      seed: () => BaseState(
        data: ApplyState(
          gender: 'Male',
          vehicleLicenceFile: File('license.jpg'),
          idImage: File('id.jpg'),
        ),
      ),
      act: (cubit) async {
        expectLater(
          cubit.uiEventStream,
          emits(isA<ApplyFailureEvent>().having(
            (e) => e.failure,
            'failure',
            isA<ServerFailure>(),
          )),
        );
        await cubit.submit();
      },
      expect: () => [
        isA<BaseState<ApplyState>>().having((s) => s.isLoading, 'isLoading', true),
        isA<BaseState<ApplyState>>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });
}
