import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:driver_app/features/home/api/client/home_api_client.dart';
import 'package:driver_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:driver_app/features/home/domain/entities/available_order.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/domain/entities/pagination.dart';
import 'package:driver_app/features/home/domain/entities/recipient.dart';
import 'package:driver_app/features/home/domain/entities/store.dart';
import 'package:driver_app/features/home/domain/repo/home_repo.dart';
import 'package:driver_app/features/home/domain/usecases/accept_order_use_case.dart';
import 'package:driver_app/features/home/domain/usecases/get_available_orders_use_case.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeApiClient extends Mock implements HomeApiClient {}

class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

class MockHomeRepo extends Mock implements HomeRepo {}

class MockGetAvailableOrdersUseCase extends Mock
    implements GetAvailableOrdersUseCase {}

class MockAcceptOrderUseCase extends Mock implements AcceptOrderUseCase {}

Pagination buildPagination({
  int page = 1,
  int pageSize = 10,
  int totalCount = 1,
  int totalPages = 1,
  bool hasNextPage = false,
  bool hasPreviousPage = false,
}) {
  return Pagination(
    page: page,
    pageSize: pageSize,
    totalCount: totalCount,
    totalPages: totalPages,
    hasNextPage: hasNextPage,
    hasPreviousPage: hasPreviousPage,
  );
}

AvailableOrder buildOrder({
  String orderId = 'order-1',
  String status = 'Pending',
  String storeName = 'Flowery Store',
  String storeAddress = '20th st, Sheikh Zayed, Giza',
  String recipientName = 'Nour Mohamed',
  String recipientCity = 'Giza',
  String recipientArea = 'Sheikh Zayed',
  int itemCount = 1,
  double total = 3000,
  DateTime? estimatedDeliveryAt,
  DateTime? deliveredAt,
  DateTime? assignedAt,
}) {
  return AvailableOrder(
    orderId: orderId,
    status: status,
    store: Store(name: storeName, address: storeAddress),
    recipient: Recipient(
      name: recipientName,
      city: recipientCity,
      area: recipientArea,
    ),
    itemCount: itemCount,
    total: total,
    estimatedDeliveryAt: estimatedDeliveryAt,
    deliveredAt: deliveredAt,
    assignedAt: assignedAt,
  );
}

AvailableOrders buildAvailableOrders({
  List<AvailableOrder>? items,
  Pagination? pagination,
}) {
  return AvailableOrders(
    items: items ?? [buildOrder()],
    pagination: pagination ?? buildPagination(),
  );
}

Map<String, dynamic> buildAvailableOrdersJson({
  bool success = true,
  String? message = 'OK',
  List<Map<String, dynamic>>? items,
  Map<String, dynamic>? pagination,
}) {
  return {
    'success': success,
    'message': message,
    'data': {
      'items':
          items ??
          [
            {
              'orderId': 'order-1',
              'status': 'Pending',
              'store': {'name': 'Flowery Store', 'address': '20th st, Giza'},
              'recipient': {
                'name': 'Nour Mohamed',
                'city': 'Giza',
                'area': 'Sheikh Zayed',
              },
              'itemCount': 2,
              'total': 3000.0,
              'estimatedDeliveryAt': '2024-09-03T11:00:00.000',
              'deliveredAt': null,
              'assignedAt': null,
            },
          ],
      'pagination':
          pagination ??
          {
            'page': 1,
            'pageSize': 10,
            'totalCount': 1,
            'totalPages': 1,
            'hasNextPage': false,
            'hasPreviousPage': false,
          },
    },
  };
}

Widget wrapWithApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

/// Replaces the default test HTTP client (which fails all network requests)
/// so [NetworkImage] widgets used by the home feature resolve successfully.
void mockNetworkImages() {
  HttpOverrides.global = _TestHttpOverrides();
}

void restoreNetworkImages() {
  HttpOverrides.global = null;
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _TestHttpClient();
}

class _TestHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpClientRequest();
}

class _TestHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _TestHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _TestHttpClientResponse();
}

class _TestHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _TestHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TestHttpHeaders extends Fake implements HttpHeaders {}
