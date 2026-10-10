import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/api/client/order_details_api_client.dart';
import 'package:driver_app/features/order_details/api/data_source_impl/remote/order_details_remote_data_source_impl.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/fixtures.dart';

class MockOrderDetailsApiClient extends Mock implements OrderDetailsApiClient {}

void main() {
  RequestOptions options() => RequestOptions(path: '/orders');

  DioException buildException({
    required DioExceptionType type,
    int? statusCode,
    dynamic data,
  }) => DioException(
    requestOptions: options(),
    type: type,
    response: statusCode == null
        ? null
        : Response(
            requestOptions: options(),
            statusCode: statusCode,
            data: data,
          ),
  );

  late MockOrderDetailsApiClient apiClient;
  late OrderDetailsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      UpdateOrderStatusRequestDto(newStatus: 'PickedUp'),
    );
    registerFallbackValue(
      ReportDriverLocationRequestDto(lat: 0, lng: 0, recordedAt: 'ts'),
    );
  });

  setUp(() {
    apiClient = MockOrderDetailsApiClient();
    dataSource = OrderDetailsRemoteDataSourceImpl(apiClient);
  });

  group('getOrderDetails', () {
    test('wraps the DTO in Success', () async {
      final dto = buildDriverOrderDetailsDto();
      when(() => apiClient.getOrderDetails(any())).thenAnswer((_) async => dto);

      final result = await dataSource.getOrderDetails(kOrderId);

      expect(result, isA<Success<DriverOrderDetailsDto>>());
      expect((result as Success<DriverOrderDetailsDto>).data, same(dto));
    });

    test('passes the orderId straight to the API client', () async {
      when(() => apiClient.getOrderDetails(any())).thenAnswer(
        (_) async => buildDriverOrderDetailsDto(),
      );

      await dataSource.getOrderDetails(kOrderId);

      verify(() => apiClient.getOrderDetails(kOrderId)).called(1);
    });

    test('maps a 404 DioException to Error(NotFoundFailure)', () async {
      when(() => apiClient.getOrderDetails(any())).thenThrow(
        buildException(type: DioExceptionType.badResponse, statusCode: 404),
      );

      final result = await dataSource.getOrderDetails(kOrderId);

      expect(result, isA<Error<DriverOrderDetailsDto>>());
      expect(
        (result as Error<DriverOrderDetailsDto>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test('maps a connection error to Error(InternetConnectionFailure)', () async {
      when(() => apiClient.getOrderDetails(any())).thenThrow(
        buildException(type: DioExceptionType.connectionError),
      );

      final result = await dataSource.getOrderDetails(kOrderId);

      expect(
        (result as Error<DriverOrderDetailsDto>).failure,
        isA<InternetConnectionFailure>(),
      );
    });

    test('maps a non-Dio exception to Error(UnknownFailure)', () async {
      when(() => apiClient.getOrderDetails(any())).thenThrow(
        StateError('something else broke'),
      );

      final result = await dataSource.getOrderDetails(kOrderId);

      expect(
        (result as Error<DriverOrderDetailsDto>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('reportDriverLocation', () {
    test('wraps the DTO in Success', () async {
      final dto = buildReportDriverLocationResponseDto();
      when(() => apiClient.reportDriverLocation(any())).thenAnswer(
        (_) async => dto,
      );

      final result = await dataSource.reportDriverLocation(
        ReportDriverLocationRequestDto(
          lat: 30.0444,
          lng: 31.2357,
          recordedAt: '2026-09-19T18:00:00Z',
        ),
      );

      expect(result, isA<Success<ReportDriverLocationResponseDto>>());
      expect((result as Success<ReportDriverLocationResponseDto>).data, same(dto));
    });

    test('forwards the request DTO unchanged', () async {
      when(() => apiClient.reportDriverLocation(any())).thenAnswer(
        (_) async => buildReportDriverLocationResponseDto(),
      );

      final request = ReportDriverLocationRequestDto(
        lat: 30.0444,
        lng: 31.2357,
        recordedAt: '2026-09-19T18:00:00Z',
      );

      await dataSource.reportDriverLocation(request);

      verify(() => apiClient.reportDriverLocation(request)).called(1);
    });

    test('calls only the location endpoint', () async {
      when(() => apiClient.reportDriverLocation(any())).thenAnswer(
        (_) async => buildReportDriverLocationResponseDto(),
      );

      await dataSource.reportDriverLocation(
        ReportDriverLocationRequestDto(lat: 1, lng: 2, recordedAt: 'ts'),
      );

      verifyNever(() => apiClient.getOrderDetails(any()));
      verifyNever(() => apiClient.updateOrderStatus(any(), any()));
    });

    test('maps a 500 response to Error(ServerFailure) with the status code', () async {
      when(() => apiClient.reportDriverLocation(any())).thenThrow(
        buildException(type: DioExceptionType.badResponse, statusCode: 500),
      );

      final result = await dataSource.reportDriverLocation(
        ReportDriverLocationRequestDto(lat: 1, lng: 2, recordedAt: 'ts'),
      );

      expect(
        (result as Error<ReportDriverLocationResponseDto>).failure,
        isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 500),
      );
    });

    test('maps a non-Dio exception to Error(UnknownFailure)', () async {
      when(() => apiClient.reportDriverLocation(any())).thenThrow(
        StateError('boom'),
      );

      final result = await dataSource.reportDriverLocation(
        ReportDriverLocationRequestDto(lat: 1, lng: 2, recordedAt: 'ts'),
      );

      expect(
        (result as Error<ReportDriverLocationResponseDto>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('updateOrderStatus', () {
    test('wraps the DTO in Success', () async {
      final dto = buildUpdateOrderStatusResponseDto();
      when(() => apiClient.updateOrderStatus(any(), any())).thenAnswer(
        (_) async => dto,
      );

      final result = await dataSource.updateOrderStatus(
        UpdateOrderStatusRequestDto(newStatus: 'PickedUp'),
        kOrderId,
      );

      expect(result, isA<Success<UpdateOrderStatusResponseDto>>());
      expect((result as Success<UpdateOrderStatusResponseDto>).data, same(dto));
    });

    test('sends the orderId as the first API client argument', () async {
      when(() => apiClient.updateOrderStatus(any(), any())).thenAnswer(
        (_) async => buildUpdateOrderStatusResponseDto(),
      );

      await dataSource.updateOrderStatus(
        UpdateOrderStatusRequestDto(newStatus: 'PickedUp'),
        kOrderId,
      );

      final captured = verify(
        () => apiClient.updateOrderStatus(captureAny(), captureAny()),
      ).captured;

      expect(captured.first, kOrderId);
      expect(
        (captured.last as UpdateOrderStatusRequestDto).newStatus,
        'PickedUp',
      );
    });

    test('maps a 409 conflict to Error(ConflictFailure) with the server message', () async {
      when(() => apiClient.updateOrderStatus(any(), any())).thenThrow(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 409,
          data: <String, dynamic>{
            'message': 'You already have an active delivery in progress.',
          },
        ),
      );

      final result = await dataSource.updateOrderStatus(
        UpdateOrderStatusRequestDto(newStatus: 'PickedUp'),
        kOrderId,
      );

      expect(
        (result as Error<UpdateOrderStatusResponseDto>).failure,
        isA<ConflictFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          'You already have an active delivery in progress.',
        ),
      );
    });

    test('maps an unauthorized response to Error(UnauthorizedFailure)', () async {
      when(() => apiClient.updateOrderStatus(any(), any())).thenThrow(
        buildException(type: DioExceptionType.badResponse, statusCode: 401),
      );

      final result = await dataSource.updateOrderStatus(
        UpdateOrderStatusRequestDto(newStatus: 'PickedUp'),
        kOrderId,
      );

      expect(
        (result as Error<UpdateOrderStatusResponseDto>).failure,
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps a non-Dio exception to Error(UnknownFailure)', () async {
      when(() => apiClient.updateOrderStatus(any(), any())).thenThrow(
        StateError('boom'),
      );

      final result = await dataSource.updateOrderStatus(
        UpdateOrderStatusRequestDto(newStatus: 'PickedUp'),
        kOrderId,
      );

      expect(
        (result as Error<UpdateOrderStatusResponseDto>).failure,
        isA<UnknownFailure>(),
      );
    });
  });
}