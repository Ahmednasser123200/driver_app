import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/api/client/pickup_location_api_client.dart';
import 'package:driver_app/features/pickup_location/api/data_source_impl/remote/pickup_location_remote_data_source_impl.dart';
import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures.dart';

class MockPickupLocationApiClient extends Mock
    implements PickupLocationApiClient {}

void main() {
  late MockPickupLocationApiClient apiClient;
  late PickupLocationRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    apiClient = MockPickupLocationApiClient();
    remoteDataSource = PickupLocationRemoteDataSourceImpl(apiClient);
  });

  test(
    'requests the route with the coordinates as longitude,latitude',
    () async {
      when(
        () => apiClient.getDrivingRoute(
          any(),
          overview: any(named: 'overview'),
          geometries: any(named: 'geometries'),
        ),
      ).thenAnswer((_) async => buildDrivingRouteResponseDto());

      final result = await remoteDataSource.getDrivingRoute(
        kDrivingRouteParams,
      );

      expect(result, isA<Success<DrivingRouteResponseDto>>());
      verify(
        () => apiClient.getDrivingRoute(
          '31.2357,30.0444;31.2302,30.0398',
          overview: 'full',
          geometries: 'geojson',
        ),
      ).called(1);
    },
  );

  test('maps a connection error to an internet connection failure', () async {
    when(
      () => apiClient.getDrivingRoute(
        any(),
        overview: any(named: 'overview'),
        geometries: any(named: 'geometries'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/route/v1/driving'),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await remoteDataSource.getDrivingRoute(kDrivingRouteParams);

    expect(result, isA<Error<DrivingRouteResponseDto>>());
    expect(
      (result as Error<DrivingRouteResponseDto>).failure,
      isA<InternetConnectionFailure>(),
    );
  });

  test('maps a timeout to a timeout failure', () async {
    when(
      () => apiClient.getDrivingRoute(
        any(),
        overview: any(named: 'overview'),
        geometries: any(named: 'geometries'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/route/v1/driving'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final result = await remoteDataSource.getDrivingRoute(kDrivingRouteParams);

    expect(result, isA<Error<DrivingRouteResponseDto>>());
    expect(
      (result as Error<DrivingRouteResponseDto>).failure,
      isA<TimeoutFailure>(),
    );
  });

  test('maps an unexpected error to an unknown failure', () async {
    when(
      () => apiClient.getDrivingRoute(
        any(),
        overview: any(named: 'overview'),
        geometries: any(named: 'geometries'),
      ),
    ).thenThrow(Exception('boom'));

    final result = await remoteDataSource.getDrivingRoute(kDrivingRouteParams);

    expect(result, isA<Error<DrivingRouteResponseDto>>());
    expect(
      (result as Error<DrivingRouteResponseDto>).failure,
      isA<UnknownFailure>(),
    );
  });
}
