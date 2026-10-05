import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/data/datasources/order_details_remote_data_source.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/data/repo/order_details_repo_impl.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockOrderDetailsRemoteDataSource extends Mock
    implements OrderDetailsRemoteDataSource {}

void main() {
  late MockOrderDetailsRemoteDataSource remoteDataSource;
  late OrderDetailsRepoImpl repository;

  setUpAll(() {
    registerFallbackValue(UpdateOrderStatusRequestDto(newStatus: 'PickedUp'));
    registerFallbackValue(
      ReportDriverLocationRequestDto(lat: 0, lng: 0, recordedAt: 'ts'),
    );
  });

  setUp(() {
    remoteDataSource = MockOrderDetailsRemoteDataSource();
    repository = OrderDetailsRepoImpl(remoteDataSource);
  });

  group('getOrderDetails', () {
    test('maps the DTO onto the domain entity on success', () async {
      when(() => remoteDataSource.getOrderDetails(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsDto()),
      );

      final result = await repository.getOrderDetails(kOrderId);

      expect(result, isA<Success>());
      final entity = (result as Success<dynamic>).data;
      expect(entity, isA<dynamic>());
      final details = entity as dynamic;
      expect(details.orderId, kOrderId);
      expect(details.orderNumber, 'ORD-12345');
      expect(details.status, 'PickedUp');
      expect(details.totalPrice, 3000.0);
      expect(details.currency, 'EGP');
      expect(details.paymentMethod, 'COD');
      expect(details.notes, 'Handle flowers with care');
      expect(details.pickupAddress.storeName, 'Flowery store');
      expect(details.pickupAddress.latitude, 30.0511);
      expect(details.userAddress.recipientName, 'Nour Mohamed');
      expect(details.recipientInfo.isGift, isTrue);
      expect(details.items, hasLength(1));
      expect(details.items.first.productName, 'Red Roses Bouquet');
      expect(details.items.first.quantity, 2);
      expect(details.timeline, hasLength(1));
      expect(details.timeline.first.status, 'Placed');
    });

    test('forwards the orderId to the data source', () async {
      when(() => remoteDataSource.getOrderDetails(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsDto()),
      );

      await repository.getOrderDetails(kOrderId);

      verify(() => remoteDataSource.getOrderDetails(kOrderId)).called(1);
    });

    test('propagates the failure unchanged', () async {
      when(() => remoteDataSource.getOrderDetails(any())).thenAnswer(
        (_) async => Error(const NotFoundFailure()),
      );

      final result = await repository.getOrderDetails(kOrderId);

      expect(result, isA<Error>());
      expect((result as Error<dynamic>).failure, isA<NotFoundFailure>());
    });
  });

  group('reportDriverLocation', () {
    test('maps the response and builds the request DTO from the params', () async {
      when(() => remoteDataSource.reportDriverLocation(any())).thenAnswer(
        (_) async => Success(buildReportDriverLocationResponseDto()),
      );

      final result = await repository.reportDriverLocation(
        const ReportDriverLocationParams(
          lat: 30.0444,
          lng: 31.2357,
          recordedAt: '2026-09-19T18:00:00Z',
        ),
      );

      expect(result, isA<Success>());
      final entity = (result as Success<dynamic>).data as dynamic;
      expect(entity.success, isTrue);
      expect(entity.recordedAt, '2026-09-19T18:00:00Z');

      final request =
          verify(
                () => remoteDataSource.reportDriverLocation(captureAny()),
              )
              .captured
              .single as ReportDriverLocationRequestDto;

      expect(request.lat, 30.0444);
      expect(request.lng, 31.2357);
      expect(request.recordedAt, '2026-09-19T18:00:00Z');
    });

    test('does not add an orderId to the location request', () async {
      when(() => remoteDataSource.reportDriverLocation(any())).thenAnswer(
        (_) async => Success(buildReportDriverLocationResponseDto()),
      );

      await repository.reportDriverLocation(
        const ReportDriverLocationParams(
          lat: 30.0444,
          lng: 31.2357,
          recordedAt: '2026-09-19T18:00:00Z',
        ),
      );

      verify(() => remoteDataSource.reportDriverLocation(any())).called(1);
      verifyNever(() => remoteDataSource.getOrderDetails(any()));
    });

    test('propagates the failure unchanged', () async {
      when(() => remoteDataSource.reportDriverLocation(any())).thenAnswer(
        (_) async => Error(const InternetConnectionFailure()),
      );

      final result = await repository.reportDriverLocation(
        const ReportDriverLocationParams(lat: 1, lng: 2, recordedAt: 'ts'),
      );

      expect(result, isA<Error>());
      expect(
        (result as Error<dynamic>).failure,
        isA<InternetConnectionFailure>(),
      );
    });
  });

  group('updateOrderStatus', () {
    test('maps the response and forwards the orderId with the new status', () async {
      when(() => remoteDataSource.updateOrderStatus(any(), any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusResponseDto()),
      );

      final result = await repository.updateOrderStatus(
        const UpdateOrderStatusParams(
          orderId: kOrderId,
          newStatus: 'OutForDelivery',
        ),
      );

      expect(result, isA<Success>());
      final entity = (result as Success<dynamic>).data as dynamic;
      expect(entity.orderId, kOrderId);
      expect(entity.status, 'PickedUp');
      expect(entity.updatedAt, '2026-09-19T18:00:00Z');

      final captured = verify(
        () => remoteDataSource.updateOrderStatus(captureAny(), captureAny()),
      ).captured;

      expect(
        (captured.first as UpdateOrderStatusRequestDto).newStatus,
        'OutForDelivery',
      );
      expect(captured.last, kOrderId);
    });

    test('propagates the conflict failure unchanged', () async {
      when(() => remoteDataSource.updateOrderStatus(any(), any())).thenAnswer(
        (_) async => Error(
          const ConflictFailure(
            serverMessage: 'You already have an active delivery in progress.',
          ),
        ),
      );

      final result = await repository.updateOrderStatus(
        const UpdateOrderStatusParams(orderId: kOrderId, newStatus: 'PickedUp'),
      );

      expect(result, isA<Error>());
      expect(
        (result as Error<dynamic>).failure,
        isA<ConflictFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          'You already have an active delivery in progress.',
        ),
      );
    });
  });
}