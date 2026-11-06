import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/api/client/routing_api_client.dart';
import 'package:driver_app/features/delivery_map/api/routing_api_module.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source_impl.dart';
import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoutingApiClient extends Mock implements RoutingApiClient {}

class _TestRoutingApiModule extends RoutingApiModule {}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({
        'routes': [
          {
            'distanceMeters': 1200,
            'duration': '180s',
            'polyline': {'encodedPolyline': '_p~iF~ps|U'},
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockRoutingApiClient mockApiClient;
  late RoutingRemoteDataSourceImpl dataSource;

  final request = ComputeRoutesRequestDto.fromCoordinates(
    origin: const GeoPoint(latitude: 30.0190, longitude: 31.2140),
    destination: const GeoPoint(latitude: 30.0250, longitude: 31.2200),
  );

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    mockApiClient = MockRoutingApiClient();
    dataSource = RoutingRemoteDataSourceImpl(mockApiClient);
  });

  group('RoutingRemoteDataSourceImpl', () {
    test('returns Success when RoutingApiClient succeeds', () async {
      const responseDto = ComputeRoutesResponseDto(
        routes: [
          ComputedRouteDto(
            distanceMeters: 3500,
            duration: '420s',
            polyline: RoutePolylineDto(encodedPolyline: '_p~iF~ps|U'),
          ),
        ],
      );

      when(() => mockApiClient.computeRoutes(request))
          .thenAnswer((_) async => responseDto);

      final result = await dataSource.fetchRoute(request);

      expect(result, isA<Success<ComputeRoutesResponseDto>>());
      final success = result as Success<ComputeRoutesResponseDto>;
      expect(success.data, responseDto);
      verify(() => mockApiClient.computeRoutes(request)).called(1);
    });

    test('maps DioExceptions via mapDioExceptionToAppFailure', () async {
      final testCases = <DioExceptionType, Type>{
        DioExceptionType.connectionTimeout: TimeoutFailure,
        DioExceptionType.connectionError: InternetConnectionFailure,
        DioExceptionType.cancel: CancelFailure,
        DioExceptionType.badCertificate: BadCertificateFailure,
        DioExceptionType.unknown: UnknownFailure,
      };

      for (final entry in testCases.entries) {
        when(() => mockApiClient.computeRoutes(request)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: entry.key,
          ),
        );

        final result = await dataSource.fetchRoute(request);

        expect(result, isA<Error<ComputeRoutesResponseDto>>());
        final error = result as Error<ComputeRoutesResponseDto>;
        expect(error.failure.runtimeType, entry.value);
      }
    });

    test('maps HTTP status codes from badResponse via mapDioExceptionToAppFailure', () async {
      final statusCases = <int, Type>{
        400: BadRequestFailure,
        401: UnauthorizedFailure,
        403: ForbiddenFailure,
        404: NotFoundFailure,
        500: ServerFailure,
      };

      for (final entry in statusCases.entries) {
        when(() => mockApiClient.computeRoutes(request)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: entry.key,
            ),
          ),
        );

        final result = await dataSource.fetchRoute(request);

        expect(result, isA<Error<ComputeRoutesResponseDto>>());
        final error = result as Error<ComputeRoutesResponseDto>;
        expect(error.failure.runtimeType, entry.value);
      }
    });

    test('returns UnknownFailure on non-Dio unexpected exception', () async {
      when(() => mockApiClient.computeRoutes(request))
          .thenThrow(Exception('unexpected'));

      final result = await dataSource.fetchRoute(request);

      expect(result, isA<Error<ComputeRoutesResponseDto>>());
      expect(
        (result as Error<ComputeRoutesResponseDto>).failure,
        isA<UnknownFailure>(),
      );
    });

    test('RoutingApiModule and RoutingApiClient execute computeRoutes over Dio', () async {
      dotenv.loadFromString(envString: 'GOOGLE_MAPS_API_KEY=test_key');
      final module = _TestRoutingApiModule();
      final dio = module.googleRoutesDio();
      dio.httpClientAdapter = _FakeHttpClientAdapter();
      final client = RoutingApiClient(dio);

      final response = await client.computeRoutes(request);
      expect(response.routes, isNotNull);
      expect(response.routes!.first.distanceMeters, 1200);
    });
  });
}
