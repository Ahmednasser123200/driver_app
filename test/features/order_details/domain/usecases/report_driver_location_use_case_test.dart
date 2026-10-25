import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo repository;
  late ReportDriverLocationUseCase useCase;
  late ReportDriverLocationParams params;

  setUpAll(() {
    registerFallbackValue(
      const ReportDriverLocationParams(lat: 0, lng: 0, recordedAt: ''),
    );
  });

  setUp(() {
    repository = MockOrderDetailsRepo();
    useCase = ReportDriverLocationUseCase(repository);
    params = const ReportDriverLocationParams(
      lat: 30.0444,
      lng: 31.2357,
      recordedAt: '2026-09-19T18:00:00Z',
    );
  });

  group('success path', () {
    test('returns the entity produced by the repository', () async {
      final entity = buildReportDriverLocationEntity();
      when(() => repository.reportDriverLocation(any()))
          .thenAnswer((_) async => Success(entity));

      final result = await useCase.execute(params);

      expect(result, isA<Success<ReportDriverLocationEntity>>());
      expect((result as Success<ReportDriverLocationEntity>).data, same(entity));
    });

    test('forwards lat, lng and recordedAt to the repository', () async {
      when(() => repository.reportDriverLocation(any())).thenAnswer(
        (_) async => Success(buildReportDriverLocationEntity()),
      );

      await useCase.execute(params);

      final captured =
          verify(() => repository.reportDriverLocation(captureAny()))
              .captured
              .single as ReportDriverLocationParams;

      expect(captured.lat, 30.0444);
      expect(captured.lng, 31.2357);
      expect(captured.recordedAt, '2026-09-19T18:00:00Z');
    });
  });

  group('failure path', () {
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
      when(() => repository.reportDriverLocation(any())).thenThrow(
        StateError('boom'),
      );

      await expectLater(
        () => useCase.execute(params),
        throwsA(isA<StateError>()),
      );
    });
  });
}