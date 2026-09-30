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
      'emits updated state when field values change',
      build: () => applyCubit,
      act: (cubit) {
        cubit.onFirstNameChanged('Jane');
        cubit.onEmailChanged('jane@example.com');
        cubit.onVehicleTypeChanged(VehicleType.motorcycle);
      },
      expect: () => [
        BaseState(data: const ApplyState(firstName: 'Jane')),
        BaseState(data: const ApplyState(firstName: 'Jane', email: 'jane@example.com')),
        BaseState(data: const ApplyState(firstName: 'Jane', email: 'jane@example.com', vehicleType: VehicleType.motorcycle)),
      ],
    );

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
      act: (cubit) => cubit.submit(),
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
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<BaseState<ApplyState>>().having((s) => s.isLoading, 'isLoading', true),
        isA<BaseState<ApplyState>>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });
}
