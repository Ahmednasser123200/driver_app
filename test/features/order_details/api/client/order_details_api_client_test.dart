import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/utils/excecute_api_call.dart';
import 'package:driver_app/features/order_details/api/client/order_details_api_client.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures what actually leaves the Dio stack instead of hitting a network.
class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? options;
  String? body;
  int statusCode = 200;
  Object? jsonBody = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;

    if (requestStream != null) {
      final bytes = <int>[];
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
      body = bytes.isEmpty ? null : utf8.decode(bytes);
    }

    return ResponseBody.fromString(
      jsonEncode(jsonBody),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const orderId = 'b1111111-1111-1111-1111-111111111111';

  late _RecordingAdapter adapter;
  late OrderDetailsApiClient client;

  void buildClient() {
    adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = adapter;
    client = OrderDetailsApiClient(dio);
  }

  setUp(buildClient);

  group('updateOrderStatus', () {
    test(
      'PATCHes the driver status route with the order id in the path',
      () async {
        await client.updateOrderStatus(
          orderId,
          UpdateOrderStatusRequestDto(
            newStatus: DriverStatusUpdate.pickedUp.wireValue,
          ),
        );

        expect(adapter.options?.method, 'PATCH');
        expect(adapter.options?.uri.path, '/order/orders/$orderId/status');
      },
    );

    test('sends the body as JSON', () async {
      await client.updateOrderStatus(
        orderId,
        UpdateOrderStatusRequestDto(
          newStatus: DriverStatusUpdate.outForDelivery.wireValue,
        ),
      );

      expect(adapter.options?.contentType, Headers.jsonContentType);
      expect(adapter.body, '{"newStatus":"OutForDelivery"}');
    });

    test('sends every driver status as its exact backend name', () async {
      for (final status in DriverStatusUpdate.values) {
        buildClient();

        await client.updateOrderStatus(
          orderId,
          UpdateOrderStatusRequestDto(newStatus: status.wireValue),
        );

        expect(
          jsonDecode(adapter.body!),
          {'newStatus': status.wireValue},
          reason: 'body must bind the ${status.name} enum name',
        );
      }
    });

    test('reports the backend binding error instead of throwing', () async {
      adapter
        ..statusCode = 400
        ..jsonBody = {
          'success': false,
          'message':
              'Failed to read parameter "UpdateOrderStatusRequestDto request" '
              'from the request body as JSON.',
          'data': null,
          'error': {'code': 'Validation', 'field': 'request'},
        };

      final result = await excecuteApiCall(
        () => client.updateOrderStatus(
          orderId,
          UpdateOrderStatusRequestDto(newStatus: 'on_the_way'),
        ),
      );

      expect(result, isA<Error>());
      expect(
        (result as Error).failure,
        isA<BadRequestFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          contains('Failed to read parameter'),
        ),
      );
    });

    test('reports an illegal transition as a conflict', () async {
      adapter
        ..statusCode = 409
        ..jsonBody = {
          'success': false,
          'message': "Cannot transition from 'Preparing' to 'PickedUp'.",
          'data': null,
          'error': {'code': 'Conflict', 'field': null},
        };

      final result = await excecuteApiCall(
        () => client.updateOrderStatus(
          orderId,
          UpdateOrderStatusRequestDto(
            newStatus: DriverStatusUpdate.pickedUp.wireValue,
          ),
        ),
      );

      expect(
        (result as Error).failure,
        isA<ConflictFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          "Cannot transition from 'Preparing' to 'PickedUp'.",
        ),
      );
    });
  });
}
