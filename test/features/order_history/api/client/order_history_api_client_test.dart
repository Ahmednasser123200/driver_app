import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driver_app/features/order_history/api/client/order_history_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

class FakeHttpClientAdapter implements HttpClientAdapter {
  late RequestOptions lastRequestOptions;
  int statusCode = 200;
  Map<String, dynamic> responseBody = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    final jsonString = jsonEncode(responseBody);
    return ResponseBody.fromString(
      jsonString,
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
  late Dio dio;
  late FakeHttpClientAdapter fakeAdapter;
  late OrderHistoryApiClient apiClient;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    fakeAdapter = FakeHttpClientAdapter();
    dio.httpClientAdapter = fakeAdapter;
    apiClient = OrderHistoryApiClient(dio);
  });

  test('getOrders sends GET to /order/drivers/me/orders with queries and parses DTO', () async {
    fakeAdapter.responseBody = orderApiResponseJson(ordersListResponseJson);

    final response = await apiClient.getOrders({'page': 1, 'pageSize': 10});

    expect(fakeAdapter.lastRequestOptions.path, '/order/drivers/me/orders');
    expect(fakeAdapter.lastRequestOptions.queryParameters, {'page': 1, 'pageSize': 10});
    expect(response.isOk, isTrue);
    expect(response.data?.items.length, 1);
    expect(response.data?.items.first.orderId, 'order123');
  });

  test('getOrderDetails sends GET to /order/drivers/me/orders/{orderId} and parses DTO', () async {
    fakeAdapter.responseBody = orderApiResponseJson(orderDetailsResponseJson);

    final response = await apiClient.getOrderDetails('order123');

    expect(
      fakeAdapter.lastRequestOptions.path,
      '/order/drivers/me/orders/order123',
    );
    expect(response.isOk, isTrue);
    expect(response.data?.orderId, 'order123');
  });

  test('getProduct sends GET to /catalog/products/{productId} and parses DTO', () async {
    fakeAdapter.responseBody = catalogApiResponseJson(productResponseJson);

    final response = await apiClient.getProduct('p1');

    expect(
      fakeAdapter.lastRequestOptions.path,
      '/catalog/products/p1',
    );
    expect(response.isOk, isTrue);
    expect(response.data?.id, 'p1');
  });
}
