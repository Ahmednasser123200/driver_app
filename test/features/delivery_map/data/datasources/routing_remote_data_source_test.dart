import 'package:dio/dio.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  late MockDio mockDio;
  late RoutingRemoteDataSourceImpl dataSource;

  const origin = LatLng(30.0190, 31.2140);
  const destination = LatLng(30.0250, 31.2200);

  setUp(() {
    mockDio = MockDio();
    dataSource = RoutingRemoteDataSourceImpl.withDio(
      dio: mockDio,
      apiKey: 'test_api_key',
    );
  });

  group('RoutingRemoteDataSourceImpl', () {
    test('Google Routes API success returns decoded RouteModel', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'routes': [
              <String, dynamic>{
                'distanceMeters': 3500,
                'duration': '420s',
                'polyline': <String, dynamic>{
                  'encodedPolyline': '_p~iF~ps|U',
                },
              },
            ],
          },
        ),
      );

      final route = await dataSource.fetchRoute(
        origin: origin,
        destination: destination,
      );

      expect(route.distanceMeters, 3500.0);
      expect(route.durationSeconds, 420.0);
      expect(route.points, isNotEmpty);
      expect(route.encodedPolyline, '_p~iF~ps|U');
    });

    test('falls back to Google Directions legacy when Routes API fails', () async {
      // 1. Google Routes throws error
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        ),
      );

      // 2. Google Directions Legacy succeeds
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'https://maps.googleapis.com/maps/api/directions/json',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'status': 'OK',
            'routes': [
              <String, dynamic>{
                'overview_polyline': <String, dynamic>{
                  'points': '_p~iF~ps|U',
                },
                'legs': [
                  <String, dynamic>{
                    'distance': <String, dynamic>{'value': 2800},
                    'duration': <String, dynamic>{'value': 300},
                  },
                ],
              },
            ],
          },
        ),
      );

      final route = await dataSource.fetchRoute(
        origin: origin,
        destination: destination,
      );

      expect(route.distanceMeters, 2800.0);
      expect(route.durationSeconds, 300.0);
      expect(route.points, isNotEmpty);
    });

    test('falls back to OSRM when all Google endpoints fail', () async {
      // 1. Google Routes fails
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        ),
      );

      // 2. Google Directions fails
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'https://maps.googleapis.com/maps/api/directions/json',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        ),
      );

      // 3. OSRM succeeds
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(that: startsWith('https://router.project-osrm.org')),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'code': 'Ok',
            'routes': [
              <String, dynamic>{
                'distance': 1500.0,
                'duration': 180.0,
                'geometry': <String, dynamic>{
                  'coordinates': [
                    [31.2140, 30.0190],
                    [31.2200, 30.0250],
                  ],
                },
              },
            ],
          },
        ),
      );

      final route = await dataSource.fetchRoute(
        origin: origin,
        destination: destination,
      );

      expect(route.distanceMeters, 1500.0);
      expect(route.durationSeconds, 180.0);
      expect(route.points.length, 2);
      expect(route.points.first.latitude, 30.0190);
      expect(route.points.first.longitude, 31.2140);
    });

    test('throws ServerFailure when OSRM code is not Ok', () async {
      dataSource = RoutingRemoteDataSourceImpl.withDio(
        dio: mockDio,
        apiKey: '', // Skips Google directly
      );

      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'code': 'NoRoute',
          },
        ),
      );

      expect(
        () => dataSource.fetchRoute(origin: origin, destination: destination),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('throws NotFoundFailure when OSRM returns empty routes or coordinates', () async {
      dataSource = RoutingRemoteDataSourceImpl.withDio(
        dio: mockDio,
        apiKey: '',
      );

      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'code': 'Ok',
            'routes': <dynamic>[],
          },
        ),
      );

      expect(
        () => dataSource.fetchRoute(origin: origin, destination: destination),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('maps DioExceptions to specific AppFailures on OSRM failure', () async {
      dataSource = RoutingRemoteDataSourceImpl.withDio(
        dio: mockDio,
        apiKey: '',
      );

      final testCases = <DioExceptionType, Type>{
        DioExceptionType.connectionTimeout: TimeoutFailure,
        DioExceptionType.connectionError: InternetConnectionFailure,
        DioExceptionType.cancel: CancelFailure,
        DioExceptionType.badCertificate: BadCertificateFailure,
        DioExceptionType.unknown: UnknownFailure,
      };

      for (final entry in testCases.entries) {
        when(
          () => mockDio.get<Map<String, dynamic>>(any()),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: entry.key,
          ),
        );

        expect(
          () => dataSource.fetchRoute(origin: origin, destination: destination),
          throwsA(isA<AppFailure>()),
        );
      }
    });

    test('maps HTTP status codes from badResponse to correct AppFailures', () async {
      dataSource = RoutingRemoteDataSourceImpl.withDio(
        dio: mockDio,
        apiKey: '',
      );

      final statusCases = <int, Type>{
        400: BadRequestFailure,
        401: UnauthorizedFailure,
        403: ForbiddenFailure,
        404: NotFoundFailure,
        500: ServerFailure,
      };

      for (final entry in statusCases.entries) {
        when(
          () => mockDio.get<Map<String, dynamic>>(any()),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: entry.key,
            ),
          ),
        );

        expect(
          () => dataSource.fetchRoute(origin: origin, destination: destination),
          throwsA(isA<AppFailure>()),
        );
      }
    });
  });
}
