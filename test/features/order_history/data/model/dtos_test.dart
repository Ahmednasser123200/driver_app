import 'dart:convert';

import 'package:driver_app/features/order_history/data/model/api_envelopes.dart';
import 'package:driver_app/features/order_history/data/model/order_details_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_history_list_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_history_request_dto.dart';
import 'package:driver_app/features/order_history/data/model/product_response_dto.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('Envelopes', () {
    test('OrderApiResponseDto isOk is true when success is true', () {
      final dto = createOrderApiResponseDto(success: true, message: 'ok');
      expect(dto.isOk, isTrue);
      final json = dto.toJson((_) => null);
      final fromJson = OrderApiResponseDto<dynamic>.fromJson(json, (_) => null);
      expect(fromJson.success, isTrue);
      expect(fromJson.message, 'ok');
    });

    test('CatalogApiResponseDto isOk is true when isSuccess is true', () {
      final dto = createCatalogApiResponseDto(isSuccess: true, message: 'ok', statusCode: '200');
      expect(dto.isOk, isTrue);
      final json = dto.toJson((_) => null);
      final fromJson = CatalogApiResponseDto<dynamic>.fromJson(json, (_) => null);
      expect(fromJson.isSuccess, isTrue);
      expect(fromJson.message, 'ok');
    });
  });

  group('OrderHistoryRequestDto', () {
    test('fromJson and toJson round trip', () {
      final dto = createOrderHistoryRequestDto(page: 2, pageSize: 20);
      final json = dto.toJson();
      final fromJson = OrderHistoryRequestDto.fromJson(json);
      expect(fromJson.page, 2);
      expect(fromJson.pageSize, 20);
    });
  });

  group('OrderHistoryResponseDto & nested DTOs', () {
    test('OrderHistoryItemDto fromJson and toJson round trip', () {
      final json = {
        'orderId': 'ord1',
        'status': 'delivered',
        'store': {
          'name': 'Store 1',
          'address': 'Address 1',
          'imageUrl': 'http://img.com/s.png',
        },
        'recipient': {
          'name': 'User 1',
          'city': 'Giza',
          'area': 'Zayed',
          'imageUrl': 'http://img.com/u.png',
        },
        'itemCount': 2,
        'total': 200.0,
        'assignedAt': '2024-09-03T10:00:00.000Z',
        'deliveredAt': '2024-09-03T11:00:00.000Z',
      };
      final dto = OrderHistoryItemDto.fromJson(json);
      expect(dto.orderId, 'ord1');
      expect(dto.toJson()['orderId'], 'ord1');
    });

    test('OrderHistoryResponseDto toEntity drops items with non-history status', () {
      final dto = createOrderHistoryResponseDto(
        items: [
          createOrderHistoryItemDto(orderId: '1', status: 'delivered'),
          createOrderHistoryItemDto(orderId: '2', status: 'pending'),
          createOrderHistoryItemDto(orderId: '3', status: 'cancelled'),
        ],
      );

      final entity = dto.toEntity();

      expect(entity.items.length, 2);
      expect(entity.items[0].orderId, '1');
      expect(entity.items[0].status, OrderStatus.completed);
      expect(entity.items[1].orderId, '3');
      expect(entity.items[1].status, OrderStatus.cancelled);
    });

    test('OrderHistoryRecipientDto toEntity joins non-empty area and city', () {
      final r1 = createOrderHistoryRecipientDto(area: 'Zayed', city: 'Giza');
      expect(r1.toEntity().address, 'Zayed, Giza');

      final r2 = createOrderHistoryRecipientDto(area: '', city: 'Giza');
      expect(r2.toEntity().address, 'Giza');

      final r3 = createOrderHistoryRecipientDto(area: 'Zayed', city: '');
      expect(r3.toEntity().address, 'Zayed');
    });

    test('OrderHistoryStoreDto toEntity maps properties', () {
      final store = createOrderHistoryStoreDto(name: 'Store A', address: 'Street A');
      final entity = store.toEntity();
      expect(entity.name, 'Store A');
      expect(entity.address, 'Street A');
    });

    test('PaginationDto toEntity maps properties', () {
      final dto = createPaginationDto(page: 1, totalCount: 100);
      final entity = dto.toEntity();
      expect(entity.page, 1);
      expect(entity.totalCount, 100);
    });
  });

  group('OrderDetailsResponseDto & nested DTOs', () {
    test('LocationDto, OrderPickupDto, OrderUserAddressDto fromJson/toJson', () {
      final locJson = {'lat': 10.0, 'lng': 20.0};
      final loc = LocationDto.fromJson(locJson);
      expect(loc.lat, 10.0);
      expect(loc.toJson()['lng'], 20.0);

      final pickup = createOrderPickupDto();
      final pickupJson = jsonDecode(jsonEncode(pickup.toJson())) as Map<String, dynamic>;
      expect(OrderPickupDto.fromJson(pickupJson).storeName, pickup.storeName);

      final userAddr = createOrderUserAddressDto();
      final userJson = jsonDecode(jsonEncode(userAddr.toJson())) as Map<String, dynamic>;
      expect(
        OrderUserAddressDto.fromJson(userJson).recipientName,
        userAddr.recipientName,
      );
    });

    test('OrderDetailsResponseDto toEntityOrNull returns null for active status', () {
      final dto = createOrderDetailsResponseDto(status: 'pending');
      expect(dto.toEntityOrNull([]), isNull);
    });

    test('OrderDetailsResponseDto toEntityOrNull builds entity and sets isCashOnDelivery = !isGift', () {
      final dtoIsGift = createOrderDetailsResponseDto(status: 'delivered', isGift: true);
      final entity1 = dtoIsGift.toEntityOrNull([]);
      expect(entity1?.isCashOnDelivery, isFalse);

      final dtoNotGift = createOrderDetailsResponseDto(status: 'delivered', isGift: false);
      final entity2 = dtoNotGift.toEntityOrNull([]);
      expect(entity2?.isCashOnDelivery, isTrue);
    });
  });

  group('ProductResponseDto & ProductIncludeDto', () {
    test('fromJson and toJson round trip', () {
      final dto = createProductResponseDto();
      final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
      final fromJson = ProductResponseDto.fromJson(json);
      expect(fromJson.id, dto.id);
      expect(fromJson.includes.first.name, dto.includes.first.name);
    });

    test('toEntity maps required product fields', () {
      final dto = createProductResponseDto(id: 'p1', name: 'Rose', price: 50.0, currency: 'EGP');
      final entity = dto.toEntity();
      expect(entity.id, 'p1');
      expect(entity.name, 'Rose');
      expect(entity.price, 50.0);
      expect(entity.currency, 'EGP');
    });
  });

  group('orderStatusFromApi', () {
    test('returns OrderStatus.completed when status is delivered (case insensitive)', () {
      expect(orderStatusFromApi('delivered'), OrderStatus.completed);
      expect(orderStatusFromApi('DELIVERED'), OrderStatus.completed);
      expect(orderStatusFromApi('Delivered'), OrderStatus.completed);
    });

    test('returns OrderStatus.cancelled when status is cancelled (case insensitive)', () {
      expect(orderStatusFromApi('cancelled'), OrderStatus.cancelled);
      expect(orderStatusFromApi('CANCELLED'), OrderStatus.cancelled);
      expect(orderStatusFromApi('Cancelled'), OrderStatus.cancelled);
    });

    test('returns null for active or unknown statuses', () {
      expect(orderStatusFromApi('pending'), isNull);
      expect(orderStatusFromApi('accepted'), isNull);
      expect(orderStatusFromApi('out_for_delivery'), isNull);
      expect(orderStatusFromApi('unknown'), isNull);
      expect(orderStatusFromApi(''), isNull);
    });
  });
}
