import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/services/media_service.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/country_entity.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/vehicle_type_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/add_application_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/get_countries_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/get_vehicle_types_use_case.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_intent.dart';

class MockAddApplicationUseCase extends Mock implements AddApplicationUseCase {}
class MockGetCountriesUseCase extends Mock implements GetCountriesUseCase {}
class MockGetVehicleTypesUseCase extends Mock implements GetVehicleTypesUseCase {}
class MockMediaService extends Mock implements MediaService {}

class FakeApplicationEntity extends Fake implements ApplicationEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeApplicationEntity());
  });

  late MockAddApplicationUseCase mockAddApplicationUseCase;
  late MockGetCountriesUseCase mockGetCountriesUseCase;
  late MockGetVehicleTypesUseCase mockGetVehicleTypesUseCase;
  late MockMediaService mockMediaService;

  const sampleCountry = CountryEntity(
    isoCode: 'EG',
    name: 'Egypt',
    phoneCode: '20',
    flag: '🇪🇬',
  );

  const sampleVehicleType = VehicleTypeEntity(
    id: '1',
    name: 'Car',
  );

  ApplyCubit createCubit() {
    return ApplyCubit(
      mockAddApplicationUseCase,
      mockGetCountriesUseCase,
      mockGetVehicleTypesUseCase,
      mockMediaService,
    );
  }

  setUp(() {
    mockAddApplicationUseCase = MockAddApplicationUseCase();
    mockGetCountriesUseCase = MockGetCountriesUseCase();
    mockGetVehicleTypesUseCase = MockGetVehicleTypesUseCase();
    mockMediaService = MockMediaService();

    when(() => mockGetCountriesUseCase.execute())
        .thenAnswer((_) async => const Success([sampleCountry]));
    when(() => mockGetVehicleTypesUseCase.execute())
        .thenAnswer((_) async => const Success([sampleVehicleType]));
  });

  group('ApplyCubit Initial & LoadInitialData', () {
    test('initial state has empty defaults and loads initial data successfully', () async {
      final cubit = createCubit();

      await pumpEventQueue();

      expect(cubit.state.countriesStatus.isLoading, false);
      expect(cubit.state.countriesStatus.data, [sampleCountry]);
      expect(cubit.state.selectedCountry, sampleCountry);
      expect(cubit.state.countryCode, '+20');

      expect(cubit.state.vehicleTypesStatus.isLoading, false);
      expect(cubit.state.vehicleTypesStatus.data, [sampleVehicleType]);
      expect(cubit.state.selectedVehicleType, sampleVehicleType);
      expect(cubit.state.vehicleType, '1');

      await cubit.close();
    });

    test('handles empty country and vehicle type lists gracefully', () async {
      when(() => mockGetCountriesUseCase.execute())
          .thenAnswer((_) async => const Success<List<CountryEntity>>([]));
      when(() => mockGetVehicleTypesUseCase.execute())
          .thenAnswer((_) async => const Success<List<VehicleTypeEntity>>([]));

      final cubit = createCubit();
      await pumpEventQueue();

      expect(cubit.state.countriesStatus.data, isEmpty);
      expect(cubit.state.vehicleTypesStatus.data, isEmpty);
      expect(cubit.state.selectedCountry, isNull);
      expect(cubit.state.selectedVehicleType, isNull);

      await cubit.close();
    });

    test('handles failure when loading countries and vehicle types', () async {
      when(() => mockGetCountriesUseCase.execute())
          .thenAnswer((_) async => const Error(ServerFailure()));
      when(() => mockGetVehicleTypesUseCase.execute())
          .thenAnswer((_) async => const Error(ServerFailure()));

      final cubit = createCubit();
      await pumpEventQueue();

      expect(cubit.state.countriesStatus.errorMessage, isNotEmpty);
      expect(cubit.state.vehicleTypesStatus.errorMessage, isNotEmpty);

      await cubit.close();
    });
  });

  group('ApplyCubit Field Change Intents', () {
    test('updates state corresponding to each change intent', () async {
      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const ChangeFirstNameIntent('Jane'));
      cubit.processIntent(const ChangeSecondNameIntent('Doe'));
      cubit.processIntent(const ChangeVehicleNumberIntent('XYZ 789'));
      cubit.processIntent(const ChangeEmailIntent('jane@example.com'));
      cubit.processIntent(const ChangePhoneIntent('0123456789'));
      cubit.processIntent(const ChangeNationalIdIntent('12345678901234'));
      cubit.processIntent(const ChangePasswordIntent('Pass123!'));
      cubit.processIntent(const ChangeConfirmPasswordIntent('Pass123!'));
      cubit.processIntent(const ChangeGenderIntent('Female'));

      const newCountry = CountryEntity(
        isoCode: 'SA',
        name: 'Saudi Arabia',
        phoneCode: '966',
        flag: '🇸🇦',
      );
      cubit.processIntent(const SelectCountryIntent(newCountry));

      const newVehicle = VehicleTypeEntity(
        id: '2',
        name: 'Motorcycle',
      );
      cubit.processIntent(const SelectVehicleTypeIntent(newVehicle));

      expect(cubit.state.firstName, 'Jane');
      expect(cubit.state.secondName, 'Doe');
      expect(cubit.state.vehicleNumber, 'XYZ 789');
      expect(cubit.state.email, 'jane@example.com');
      expect(cubit.state.phoneNumber, '0123456789');
      expect(cubit.state.nationalId, '12345678901234');
      expect(cubit.state.password, 'Pass123!');
      expect(cubit.state.confirmPassword, 'Pass123!');
      expect(cubit.state.gender, 'Female');
      expect(cubit.state.selectedCountry, newCountry);
      expect(cubit.state.countryCode, '+966');
      expect(cubit.state.selectedVehicleType, newVehicle);
      expect(cubit.state.vehicleType, '2');

      await cubit.close();
    });
  });

  group('ApplyCubit Media Picking Intents', () {
    test('PickLicenseImageIntent updates state when path is returned', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => '/path/to/license.jpg');

      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const PickLicenseImageIntent());
      await pumpEventQueue();

      expect(cubit.state.vehicleLicencePath, '/path/to/license.jpg');
      verify(() => mockMediaService.pickImageFromGallery()).called(1);

      await cubit.close();
    });

    test('PickLicenseImageIntent does not change path when null is returned', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => null);

      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const PickLicenseImageIntent());
      await pumpEventQueue();

      expect(cubit.state.vehicleLicencePath, isNull);

      await cubit.close();
    });

    test('PickIdImageIntent updates state when path is returned', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => '/path/to/id.jpg');

      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const PickIdImageIntent());
      await pumpEventQueue();

      expect(cubit.state.idImagePath, '/path/to/id.jpg');
      verify(() => mockMediaService.pickImageFromGallery()).called(1);

      await cubit.close();
    });

    test('PickIdImageIntent does not change path when null is returned', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => null);

      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const PickIdImageIntent());
      await pumpEventQueue();

      expect(cubit.state.idImagePath, isNull);

      await cubit.close();
    });
  });

  group('ApplyCubit Submit Validation & Execution', () {
    test('emits ApplyGenderMissingEvent when gender is null', () async {
      final cubit = createCubit();
      await pumpEventQueue();

      expectLater(
        cubit.uiEventStream,
        emits(isA<ApplyGenderMissingEvent>()),
      );

      cubit.processIntent(const SubmitApplicationIntent());
      await pumpEventQueue();

      verifyNever(() => mockAddApplicationUseCase.execute(any()));
      await cubit.close();
    });

    test('emits ApplyLicenseMissingEvent when vehicleLicencePath is null or empty', () async {
      final cubit = createCubit();
      await pumpEventQueue();
      cubit.processIntent(const ChangeGenderIntent('Male'));

      expectLater(
        cubit.uiEventStream,
        emits(isA<ApplyLicenseMissingEvent>()),
      );

      cubit.processIntent(const SubmitApplicationIntent());
      await pumpEventQueue();

      verifyNever(() => mockAddApplicationUseCase.execute(any()));
      await cubit.close();
    });

    test('emits ApplyIdImageMissingEvent when idImagePath is null or empty', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => '/path/license.jpg');

      final cubit = createCubit();
      await pumpEventQueue();
      cubit.processIntent(const ChangeGenderIntent('Male'));
      cubit.processIntent(const PickLicenseImageIntent());
      await pumpEventQueue();

      expectLater(
        cubit.uiEventStream,
        emits(isA<ApplyIdImageMissingEvent>()),
      );

      cubit.processIntent(const SubmitApplicationIntent());
      await pumpEventQueue();

      verifyNever(() => mockAddApplicationUseCase.execute(any()));
      await cubit.close();
    });

    test('executes usecase successfully and emits ApplySuccessEvent', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => '/path/file.jpg');
      when(() => mockAddApplicationUseCase.execute(any()))
          .thenAnswer((_) async => const Success(null));

      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const ChangeFirstNameIntent('Jane'));
      cubit.processIntent(const ChangeSecondNameIntent('Doe'));
      cubit.processIntent(const ChangeGenderIntent('Female'));
      cubit.processIntent(const PickLicenseImageIntent());
      cubit.processIntent(const PickIdImageIntent());
      await pumpEventQueue();

      expectLater(
        cubit.uiEventStream,
        emits(isA<ApplySuccessEvent>()),
      );

      cubit.processIntent(const SubmitApplicationIntent());
      await pumpEventQueue();

      verify(() => mockAddApplicationUseCase.execute(any())).called(1);
      expect(cubit.state.applyStatus.isLoading, false);

      await cubit.close();
    });

    test('executes usecase and handles failure emitting ApplyFailureEvent', () async {
      when(() => mockMediaService.pickImageFromGallery())
          .thenAnswer((_) async => '/path/file.jpg');
      when(() => mockAddApplicationUseCase.execute(any()))
          .thenAnswer((_) async => const Error(ServerFailure()));

      final cubit = createCubit();
      await pumpEventQueue();

      cubit.processIntent(const ChangeGenderIntent('Male'));
      cubit.processIntent(const PickLicenseImageIntent());
      cubit.processIntent(const PickIdImageIntent());
      await pumpEventQueue();

      expectLater(
        cubit.uiEventStream,
        emits(isA<ApplyFailureEvent>().having(
          (e) => e.failure,
          'failure',
          isA<ServerFailure>(),
        )),
      );

      cubit.processIntent(const SubmitApplicationIntent());
      await pumpEventQueue();

      verify(() => mockAddApplicationUseCase.execute(any())).called(1);
      expect(cubit.state.applyStatus.isLoading, false);
      expect(cubit.state.applyStatus.errorMessage, isNotEmpty);

      await cubit.close();
    });
  });
}
