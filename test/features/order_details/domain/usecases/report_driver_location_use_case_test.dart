import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/services/location/geolocator_wrapper.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

class MockGeolocatorWrapper extends Mock implements GeolocatorWrapper {}

void main() {
  late MockOrderDetailsRepo repository;
  late MockGeolocatorWrapper geolocatorWrapper;
  late ReportDriverLocationUseCase useCase;
  late ReportDriverLocationParams params;

  setUpAll(() {
    registerFallbackValue(
      const ReportDriverLocationParams(lat: 0, lng: 0, recordedAt: ''),
    );
  });

  setUp(() {
    repository = MockOrderDetailsRepo();
    geolocatorWrapper = MockGeolocatorWrapper();
    useCase = ReportDriverLocationUseCase(repository, geolocatorWrapper);
    params = const ReportDriverLocationParams(
      lat: 30.0444,
      lng: 31.2357,
      recordedAt: '2026-09-19T18:00:00Z',
    );
  });

  group('execute (direct call)', () {
    test('returns the entity produced by the repository', () async {
      final entity = buildReportDriverLocationEntity();
      when(
        () => repository.reportDriverLocation(any()),
      ).thenAnswer((_) async => Success(entity));

      final result = await useCase.execute(params);

      expect(result, isA<Success<ReportDriverLocationEntity>>());
      expect(
        (result as Success<ReportDriverLocationEntity>).data,
        same(entity),
      );
    });

    test('forwards lat, lng and recordedAt to the repository', () async {
      when(
        () => repository.reportDriverLocation(any()),
      ).thenAnswer((_) async => Success(buildReportDriverLocationEntity()));

      await useCase.execute(params);

      final captured =
          verify(
                () => repository.reportDriverLocation(captureAny()),
              ).captured.single
              as ReportDriverLocationParams;

      expect(captured.lat, 30.0444);
      expect(captured.lng, 31.2357);
      expect(captured.recordedAt, '2026-09-19T18:00:00Z');
    });

    test('returns the error emitted by the repository', () async {
      when(() => repository.reportDriverLocation(any())).thenAnswer(
        (_) async => Error<ReportDriverLocationEntity>(
          const InternetConnectionFailure(),
        ),
      );

      final result = await useCase.execute(params);

      expect(result, isA<Error<ReportDriverLocationEntity>>());
      expect(
        (result as Error<ReportDriverLocationEntity>).failure,
        isA<InternetConnectionFailure>(),
      );
    });

    test('propagates thrown exceptions', () async {
      when(
        () => repository.reportDriverLocation(any()),
      ).thenThrow(StateError('boom'));

      await expectLater(
        () => useCase.execute(params),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('start (streaming & displacement throttling)', () {
    late StreamController<BaseResponse<DriverLocation>>
    locationStreamController;
    late List<AppFailure> errors;

    setUp(() {
      locationStreamController =
          StreamController<BaseResponse<DriverLocation>>.broadcast();
      when(
        () => repository.driverLocationStream,
      ).thenAnswer((_) => locationStreamController.stream);
      errors = [];
    });

    tearDown(() async {
      await locationStreamController.close();
    });

    test('immediately reports the first position received', () async {
      final entity = buildReportDriverLocationEntity();
      when(
        () => repository.reportDriverLocation(any()),
      ).thenAnswer((_) async => Success(entity));

      final results = <BaseResponse<ReportDriverLocationEntity>>[];
      final subscription = useCase.start(
        onReportResult: results.add,
        onLocationError: errors.add,
      );

      const firstPos = DriverLocation(latitude: 30.0444, longitude: 31.2357);
      locationStreamController.add(const Success(firstPos));
      await pumpEventQueue();

      expect(results, hasLength(1));
      expect(results.first, isA<Success<ReportDriverLocationEntity>>());
      expect(errors, isEmpty);

      final captured =
          verify(
                () => repository.reportDriverLocation(captureAny()),
              ).captured.single
              as ReportDriverLocationParams;
      expect(captured.lat, 30.0444);
      expect(captured.lng, 31.2357);
      expect(captured.recordedAt, isNotEmpty);

      await subscription.cancel();
    });

    test(
      'throttles positions when displacement is less than 50 meters',
      () async {
        when(
          () => repository.reportDriverLocation(any()),
        ).thenAnswer((_) async => Success(buildReportDriverLocationEntity()));

        final results = <BaseResponse<ReportDriverLocationEntity>>[];
        final subscription = useCase.start(
          onReportResult: results.add,
          onLocationError: errors.add,
        );

        const pos1 = DriverLocation(latitude: 30.0444, longitude: 31.2357);
        const pos2 = DriverLocation(latitude: 30.0445, longitude: 31.2358);

        when(
          () => geolocatorWrapper.distanceBetween(
            pos1.latitude,
            pos1.longitude,
            pos2.latitude,
            pos2.longitude,
          ),
        ).thenReturn(15.0);

        locationStreamController.add(const Success(pos1));
        await pumpEventQueue();

        locationStreamController.add(const Success(pos2));
        await pumpEventQueue();

        expect(results, hasLength(1));
        verify(() => repository.reportDriverLocation(any())).called(1);

        await subscription.cancel();
      },
    );

    test(
      'reports subsequent position when displacement is >= 50 meters',
      () async {
        when(
          () => repository.reportDriverLocation(any()),
        ).thenAnswer((_) async => Success(buildReportDriverLocationEntity()));

        final results = <BaseResponse<ReportDriverLocationEntity>>[];
        final subscription = useCase.start(
          onReportResult: results.add,
          onLocationError: errors.add,
        );

        const pos1 = DriverLocation(latitude: 30.0444, longitude: 31.2357);
        const pos2 = DriverLocation(latitude: 30.0450, longitude: 31.2365);

        when(
          () => geolocatorWrapper.distanceBetween(
            pos1.latitude,
            pos1.longitude,
            pos2.latitude,
            pos2.longitude,
          ),
        ).thenReturn(75.0);

        locationStreamController.add(const Success(pos1));
        await pumpEventQueue();

        locationStreamController.add(const Success(pos2));
        await pumpEventQueue();

        expect(results, hasLength(2));
        verify(() => repository.reportDriverLocation(any())).called(2);

        await subscription.cancel();
      },
    );

    test('forwards failure response to onReportResult callback', () async {
      when(() => repository.reportDriverLocation(any())).thenAnswer(
        (_) async => Error<ReportDriverLocationEntity>(
          const ServerFailure(statusCode: 500),
        ),
      );

      final results = <BaseResponse<ReportDriverLocationEntity>>[];
      final subscription = useCase.start(
        onReportResult: results.add,
        onLocationError: errors.add,
      );

      locationStreamController.add(
        const Success(DriverLocation(latitude: 30.0444, longitude: 31.2357)),
      );
      await pumpEventQueue();

      expect(results, hasLength(1));
      expect(results.first, isA<Error<ReportDriverLocationEntity>>());

      await subscription.cancel();
    });

    test(
      'forwards location stream errors to onLocationError callback',
      () async {
        final results = <BaseResponse<ReportDriverLocationEntity>>[];
        final subscription = useCase.start(
          onReportResult: results.add,
          onLocationError: errors.add,
        );

        locationStreamController.add(
          const Error<DriverLocation>(UnknownFailure()),
        );
        await pumpEventQueue();

        expect(errors, hasLength(1));
        expect(errors.single, isA<UnknownFailure>());
        expect(results, isEmpty);
        verifyNever(() => repository.reportDriverLocation(any()));

        await subscription.cancel();
      },
    );

    test('canceling subscription stops location reporting', () async {
      when(
        () => repository.reportDriverLocation(any()),
      ).thenAnswer((_) async => Success(buildReportDriverLocationEntity()));

      final results = <BaseResponse<ReportDriverLocationEntity>>[];
      final subscription = useCase.start(
        onReportResult: results.add,
        onLocationError: errors.add,
      );

      await subscription.cancel();

      locationStreamController.add(
        const Success(DriverLocation(latitude: 30.0444, longitude: 31.2357)),
      );
      await pumpEventQueue();

      expect(results, isEmpty);
      verifyNever(() => repository.reportDriverLocation(any()));
    });
  });
}
