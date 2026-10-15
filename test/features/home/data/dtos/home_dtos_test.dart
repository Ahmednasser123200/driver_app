import 'package:driver_app/features/home/data/dtos/available_order_dto.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_data_dto.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:driver_app/features/home/data/dtos/pagination_dto.dart';
import 'package:driver_app/features/home/data/dtos/recipient_dto.dart';
import 'package:driver_app/features/home/data/dtos/store_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../home_test_fixtures.dart';

void main() {
  group('StoreDto', () {
    test('fromJson maps fields and toDomain converts', () {
      final dto = StoreDto.fromJson(const {
        'name': 'Flowery Store',
        'address': '20th st, Giza',
      });

      expect(dto.name, 'Flowery Store');
      expect(dto.address, '20th st, Giza');

      final store = dto.toDomain();
      expect(store.name, 'Flowery Store');
      expect(store.address, '20th st, Giza');
    });

    test('toJson keeps the expected keys', () {
      final json = StoreDto(
        name: 'Flowery Store',
        address: '20th st, Giza',
      ).toJson();

      expect(json, {'name': 'Flowery Store', 'address': '20th st, Giza'});
    });
  });

  group('RecipientDto', () {
    test('fromJson maps fields and toDomain converts', () {
      final dto = RecipientDto.fromJson(const {
        'name': 'Nour Mohamed',
        'city': 'Giza',
        'area': 'Sheikh Zayed',
      });

      expect(dto.name, 'Nour Mohamed');
      expect(dto.city, 'Giza');
      expect(dto.area, 'Sheikh Zayed');

      final recipient = dto.toDomain();
      expect(recipient.name, 'Nour Mohamed');
      expect(recipient.city, 'Giza');
      expect(recipient.area, 'Sheikh Zayed');
    });

    test('toJson keeps the expected keys', () {
      final json = RecipientDto(
        name: 'Nour Mohamed',
        city: 'Giza',
        area: 'Sheikh Zayed',
      ).toJson();

      expect(json, {
        'name': 'Nour Mohamed',
        'city': 'Giza',
        'area': 'Sheikh Zayed',
      });
    });
  });

  group('PaginationDto', () {
    test('fromJson maps fields and toDomain converts', () {
      final dto = PaginationDto.fromJson(const {
        'page': 2,
        'pageSize': 10,
        'totalCount': 25,
        'totalPages': 3,
        'hasNextPage': true,
        'hasPreviousPage': true,
      });

      expect(dto.page, 2);
      expect(dto.pageSize, 10);
      expect(dto.totalCount, 25);
      expect(dto.totalPages, 3);
      expect(dto.hasNextPage, isTrue);
      expect(dto.hasPreviousPage, isTrue);

      final pagination = dto.toDomain();
      expect(pagination.page, 2);
      expect(pagination.pageSize, 10);
      expect(pagination.totalCount, 25);
      expect(pagination.totalPages, 3);
      expect(pagination.hasNextPage, isTrue);
      expect(pagination.hasPreviousPage, isTrue);
    });

    test('toJson round trips through fromJson', () {
      final dto = PaginationDto(
        page: 1,
        pageSize: 10,
        totalCount: 1,
        totalPages: 1,
        hasNextPage: false,
        hasPreviousPage: false,
      );

      final restored = PaginationDto.fromJson(dto.toJson());
      expect(restored.page, dto.page);
      expect(restored.pageSize, dto.pageSize);
      expect(restored.totalCount, dto.totalCount);
      expect(restored.totalPages, dto.totalPages);
      expect(restored.hasNextPage, dto.hasNextPage);
      expect(restored.hasPreviousPage, dto.hasPreviousPage);
    });
  });

  group('AvailableOrderDto', () {
    test('fromJson parses nested objects and dates', () {
      final dto = AvailableOrderDto.fromJson(const {
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
      });

      expect(dto.orderId, 'order-1');
      expect(dto.status, 'Pending');
      expect(dto.store.name, 'Flowery Store');
      expect(dto.recipient.name, 'Nour Mohamed');
      expect(dto.itemCount, 2);
      expect(dto.total, 3000.0);
      expect(dto.estimatedDeliveryAt, DateTime(2024, 9, 3, 11));
      expect(dto.deliveredAt, isNull);
      expect(dto.assignedAt, isNull);
    });

    test('toDomain converts nested values', () {
      final dto = AvailableOrderDto.fromJson(const {
        'orderId': 'order-1',
        'status': 'Picked',
        'store': {'name': 'Flowery Store', 'address': '20th st, Giza'},
        'recipient': {
          'name': 'Nour Mohamed',
          'city': 'Giza',
          'area': 'Sheikh Zayed',
        },
        'itemCount': 2,
        'total': 1500.5,
      });

      final order = dto.toDomain();
      expect(order.orderId, 'order-1');
      expect(order.status, 'Picked');
      expect(order.store.name, 'Flowery Store');
      expect(order.recipient.city, 'Giza');
      expect(order.recipient.area, 'Sheikh Zayed');
      expect(order.itemCount, 2);
      expect(order.total, 1500.5);
      expect(order.estimatedDeliveryAt, isNull);
    });
  });

  group('AvailableOrdersDataDto', () {
    test('fromJson maps items and pagination then toDomain converts', () {
      final dto = AvailableOrdersDataDto.fromJson({
        'items':
            (buildAvailableOrdersJson()['data']
                as Map<String, dynamic>)['items'],
        'pagination': {
          'page': 1,
          'pageSize': 10,
          'totalCount': 1,
          'totalPages': 1,
          'hasNextPage': false,
          'hasPreviousPage': false,
        },
      });

      expect(dto.items, hasLength(1));
      expect(dto.pagination.page, 1);

      final orders = dto.toDomain();
      expect(orders.items, hasLength(1));
      expect(orders.items.first.orderId, 'order-1');
      expect(orders.pagination.totalCount, 1);
    });
  });

  group('AvailableOrdersResponseDto', () {
    test('fromJson parses the full response and toDomain converts', () {
      final dto = AvailableOrdersResponseDto.fromJson(
        buildAvailableOrdersJson(),
      );

      expect(dto.success, isTrue);
      expect(dto.message, 'OK');
      expect(dto.data.items, hasLength(1));

      final orders = dto.toDomain();
      expect(orders.items, hasLength(1));
      expect(orders.items.first.orderId, 'order-1');
      expect(orders.items.first.store.name, 'Flowery Store');
      expect(orders.pagination.hasNextPage, isFalse);
    });

    test('toJson exposes the top-level fields', () {
      final dto = AvailableOrdersResponseDto.fromJson(
        buildAvailableOrdersJson(),
      );

      final json = dto.toJson();
      expect(json['success'], dto.success);
      expect(json['message'], dto.message);
    });
  });
}
