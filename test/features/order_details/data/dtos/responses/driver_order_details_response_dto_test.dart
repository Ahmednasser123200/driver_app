import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  group('fromJson', () {
    test('parses every top-level field of the API contract', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.orderId, kOrderId);
      expect(dto.orderNumber, 'ORD-12345');
      expect(dto.status, 'PickedUp');
      expect(dto.totalPrice, 3000.0);
      expect(dto.currency, 'EGP');
      expect(dto.paymentMethod, 'COD');
      expect(dto.notes, 'Handle flowers with care');
    });

    test('parses the nested pickup address', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.pickupAddress.storeName, 'Flowery store');
      expect(dto.pickupAddress.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.pickupAddress.latitude, 30.0511);
      expect(dto.pickupAddress.longitude, 31.3656);
    });

    test('parses the nested user address including the phone', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.userAddress.recipientName, 'Nour Mohamed');
      expect(dto.userAddress.phone, '+201012345678');
      expect(dto.userAddress.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.userAddress.latitude, 30.0444);
      expect(dto.userAddress.longitude, 31.2357);
    });

    test('parses the nested recipient info and the gift flag', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.recipientInfo.isGift, isTrue);
      expect(dto.recipientInfo.recipientName, 'Sara');
      expect(dto.recipientInfo.recipientPhone, '+201012345678');
    });

    test('parses the items list', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.items, hasLength(1));
      expect(dto.items.first.productId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(dto.items.first.productName, 'Red Roses Bouquet');
      expect(dto.items.first.quantity, 2);
      expect(dto.items.first.unitPrice, 1500.0);
      expect(dto.items.first.imageUrl, 'https://example.com/rose.png');
    });

    test('parses the timeline list keeping the backend order', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.timeline, hasLength(2));
      expect(dto.timeline.first.status, 'Placed');
      expect(dto.timeline.first.timestamp, '2026-09-19T17:00:00Z');
      expect(dto.timeline.last.status, 'PickedUp');
      expect(dto.timeline.last.timestamp, '2026-09-19T17:30:00Z');
    });

    test('treats a missing notes key as null', () {
      final json = driverOrderDetailsJson()..remove('notes');

      expect(DriverOrderDetailsDto.fromJson(json).notes, isNull);
    });

    test('treats an explicit null notes value as null', () {
      final json = driverOrderDetailsJson()..['notes'] = null;

      expect(DriverOrderDetailsDto.fromJson(json).notes, isNull);
    });
  });

  group('toJson', () {
    test('emits the exact camelCase keys expected by the backend', () {
      final json = buildDriverOrderDetailsDto().toJson();

      expect(
        json.keys.toSet(),
        {
          'orderId',
          'orderNumber',
          'status',
          'totalPrice',
          'currency',
          'paymentMethod',
          'notes',
          'pickupAddress',
          'userAddress',
          'recipientInfo',
          'items',
          'timeline',
        },
      );
    });

    test('emits the scalar field values unchanged', () {
      final json = buildDriverOrderDetailsDto().toJson();

      expect(json['orderId'], kOrderId);
      expect(json['orderNumber'], 'ORD-12345');
      expect(json['status'], 'PickedUp');
      expect(json['totalPrice'], 3000.0);
      expect(json['currency'], 'EGP');
      expect(json['paymentMethod'], 'COD');
      expect(json['notes'], 'Handle flowers with care');
    });

    test('embeds the nested DTO instances instead of nested maps', () {
      final dto = buildDriverOrderDetailsDto();

      final json = dto.toJson();

      expect(json['pickupAddress'], same(dto.pickupAddress));
      expect(json['userAddress'], same(dto.userAddress));
      expect(json['recipientInfo'], same(dto.recipientInfo));
      expect(json['items'], same(dto.items));
      expect(json['timeline'], same(dto.timeline));
    });

    test('is not a full inverse of fromJson because toJson keeps DTOs', () {
      // `explicitToJson` is disabled, so toJson() output is not directly
      // re-parsable by fromJson().
      expect(
        () => DriverOrderDetailsDto.fromJson(
          buildDriverOrderDetailsDto().toJson(),
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromJson then toJson preserves the scalar contract', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      final json = dto.toJson();

      expect(json['orderId'], kOrderId);
      expect(json['orderNumber'], 'ORD-12345');
      expect(json['totalPrice'], 3000.0);
      expect(json['notes'], 'Handle flowers with care');
      expect(json['items'], hasLength(1));
      expect(json['timeline'], hasLength(2));
    });
  });

  group('toDomain', () {
    test('maps every scalar field onto the entity', () {
      final entity = buildDriverOrderDetailsDto().toDomain();

      expect(entity.orderId, kOrderId);
      expect(entity.orderNumber, 'ORD-12345');
      expect(entity.status, 'PickedUp');
      expect(entity.totalPrice, 3000.0);
      expect(entity.currency, 'EGP');
      expect(entity.paymentMethod, 'COD');
      expect(entity.notes, 'Handle flowers with care');
    });

    test('maps the nested addresses and recipient info', () {
      final entity = buildDriverOrderDetailsDto().toDomain();

      expect(entity.pickupAddress.storeName, 'Flowery store');
      expect(entity.pickupAddress.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(entity.pickupAddress.latitude, 30.0511);
      expect(entity.pickupAddress.longitude, 31.3656);

      expect(entity.userAddress.recipientName, 'Nour Mohamed');
      expect(entity.userAddress.phone, '+201012345678');
      expect(entity.userAddress.latitude, 30.0444);
      expect(entity.userAddress.longitude, 31.2357);

      expect(entity.recipientInfo.isGift, isTrue);
      expect(entity.recipientInfo.recipientName, 'Sara');
      expect(entity.recipientInfo.recipientPhone, '+201012345678');
    });

    test('converts every item in the list', () {
      final entity = buildDriverOrderDetailsDto().toDomain();

      expect(entity.items, hasLength(1));
      expect(entity.items.first.productId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(entity.items.first.productName, 'Red Roses Bouquet');
      expect(entity.items.first.quantity, 2);
      expect(entity.items.first.unitPrice, 1500.0);
      expect(entity.items.first.imageUrl, 'https://example.com/rose.png');
    });

    test('converts every timeline entry and preserves order', () {
      final entity = DriverOrderDetailsDto.fromJson(
        driverOrderDetailsJson(),
      ).toDomain();

      expect(entity.timeline, hasLength(2));
      expect(entity.timeline.first.status, 'Placed');
      expect(entity.timeline.last.status, 'PickedUp');
      expect(entity.timeline.last.timestamp, '2026-09-19T17:30:00Z');
    });

    test('substitutes an empty string when notes is null', () {
      final entity = buildDriverOrderDetailsDto(notes: null).toDomain();

      expect(entity.notes, '');
    });

    test('keeps a non-null notes value untouched', () {
      final entity = buildDriverOrderDetailsDto(notes: 'Leave at door').toDomain();

      expect(entity.notes, 'Leave at door');
    });

    test('does not share the mutable list with the DTO', () {
      final dto = buildDriverOrderDetailsDto();

      dto.toDomain().items.add(buildOrderItemEntity());

      expect(dto.items, hasLength(1));
    });
  });
}