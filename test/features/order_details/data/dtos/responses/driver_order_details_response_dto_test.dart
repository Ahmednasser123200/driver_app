import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  group('fromJson', () {
    test('parses the payload the live driver endpoint returns', () {
      final dto = DriverOrderDetailsDto.fromJson(
        realDriverOrderDetailsResponse(),
      );

      expect(dto.orderId, kRealOrderId);
      expect(dto.status, OrderStatus.pending);
      expect(dto.isGift, isFalse);
      expect(dto.items, hasLength(2));
      expect(dto.items?.first.productName, 'Glass Flower Vase');
      expect(dto.pickupAddress?.storeName, 'Unknown Store');
      expect(dto.pickupAddress?.addressLine, 'Store Location');
      expect(dto.pickupAddress?.location?.lat, 0);
      expect(dto.userAddress?.recipientName, 'Sarah Ahmed');
      expect(dto.userAddress?.phone, '+201001234567');
      expect(dto.userAddress?.addressLine, '45 El-Nahr Street, Apartment 4B');

      // Keys the driver endpoint does not send stay null instead of throwing.
      expect(dto.orderNumber, isNull);
      expect(dto.totalPrice, isNull);
      expect(dto.timeline, isNull);
    });

    test('parses an order wrapped in the standard API response envelope', () {
      final dto = DriverOrderDetailsDto.fromJson(<String, dynamic>{
        'success': true,
        'message': 'Order details retrieved successfully.',
        'data': driverOrderDetailsJson(),
        'error': null,
      });

      expect(dto.orderId, kOrderId);
      expect(dto.orderNumber, 'ORD-12345');
      expect(dto.items, hasLength(1));
      expect(dto.pickupAddress?.storeName, 'Flowery store');
      expect(dto.userAddress?.recipientName, 'Nour Mohamed');
    });

    test('parses every top-level field of the API contract', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.orderId, kOrderId);
      expect(dto.orderNumber, 'ORD-12345');
      expect(dto.status, OrderStatus.pickedUp);
      expect(dto.isGift, isTrue);
      expect(dto.totalPrice, 3000.0);
      expect(dto.currency, 'EGP');
      expect(dto.paymentMethod, 'COD');
      expect(dto.notes, 'Handle flowers with care');
    });

    test('parses the nested pickup address from the pickup key', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.pickupAddress?.storeName, 'Flowery store');
      expect(dto.pickupAddress?.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.pickupAddress?.location?.lat, 30.0511);
      expect(dto.pickupAddress?.location?.lng, 31.3656);
    });

    test('parses the nested user address including the recipient phone', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.userAddress?.recipientName, 'Nour Mohamed');
      expect(dto.userAddress?.phone, '+201012345678');
      expect(dto.userAddress?.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.userAddress?.location?.lat, 30.0444);
      expect(dto.userAddress?.location?.lng, 31.2357);
    });

    test('parses the items list', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.items, hasLength(1));
      expect(
        dto.items?.first.productId,
        '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      );
      expect(dto.items?.first.productName, 'Red Roses Bouquet');
      expect(dto.items?.first.quantity, 2);
      expect(dto.items?.first.unitPrice, 1500.0);
      expect(dto.items?.first.imageUrl, 'https://example.com/rose.png');
    });

    test('parses the timeline list keeping the backend order', () {
      final dto = DriverOrderDetailsDto.fromJson(driverOrderDetailsJson());

      expect(dto.timeline, hasLength(2));
      expect(dto.timeline?.first.status, 'Placed');
      expect(dto.timeline?.first.timestamp, '2026-09-19T17:00:00Z');
      expect(dto.timeline?.last.status, 'PickedUp');
      expect(dto.timeline?.last.timestamp, '2026-09-19T17:30:00Z');
    });

    test('parses the nested recipient info when the backend sends it', () {
      final json = driverOrderDetailsJson()
        ..['recipientInfo'] = <String, dynamic>{
          'isGift': true,
          'recipientName': 'Sara',
          'recipientPhone': '+201099999999',
        };

      final dto = DriverOrderDetailsDto.fromJson(json);

      expect(dto.recipientInfo?.isGift, isTrue);
      expect(dto.recipientInfo?.recipientName, 'Sara');
      expect(dto.recipientInfo?.recipientPhone, '+201099999999');
    });

    test('treats missing and null scalar keys as null', () {
      final withoutNotes = driverOrderDetailsJson()..remove('notes');
      final nullNotes = driverOrderDetailsJson()..['notes'] = null;

      expect(DriverOrderDetailsDto.fromJson(withoutNotes).notes, isNull);
      expect(DriverOrderDetailsDto.fromJson(nullNotes).notes, isNull);
    });

    test('parses a minimal payload instead of throwing', () {
      final dto = DriverOrderDetailsDto.fromJson(<String, dynamic>{
        'orderId': kOrderId,
        'status': 'Preparing',
      });

      expect(dto.orderId, kOrderId);
      expect(dto.status, OrderStatus.pending);
      expect(dto.items, isNull);
      expect(dto.pickupAddress, isNull);
      expect(dto.userAddress, isNull);
    });

    test('parses an empty payload instead of throwing', () {
      final dto = DriverOrderDetailsDto.fromJson(const <String, dynamic>{});

      expect(dto.orderId, isNull);
      expect(dto.status, OrderStatus.pending);
    });

    group('status mapping', () {
      final cases = <String, OrderStatus>{
        'Placed': OrderStatus.pending,
        'PendingPayment': OrderStatus.pending,
        'PaymentFailed': OrderStatus.pending,
        'Preparing': OrderStatus.pending,
        'PickedUp': OrderStatus.pickedUp,
        'OutForDelivery': OrderStatus.outForDelivery,
        'AwaitingDeliveryConfirmation': OrderStatus.arrived,
        'Delivered': OrderStatus.delivered,
        'Cancelled': OrderStatus.cancelled,
      };

      cases.forEach((backendStatus, expected) {
        test('maps $backendStatus to ${expected.name}', () {
          final dto = DriverOrderDetailsDto.fromJson(<String, dynamic>{
            'orderId': kOrderId,
            'status': backendStatus,
          });

          expect(dto.status, expected);
        });
      });

      test('falls back to pending for an unknown status', () {
        final dto = DriverOrderDetailsDto.fromJson(<String, dynamic>{
          'orderId': kOrderId,
          'status': 'SomethingElse',
        });

        expect(dto.status, OrderStatus.pending);
      });

      test('falls back to pending for a missing status', () {
        expect(
          DriverOrderDetailsDto.fromJson(<String, dynamic>{
            'orderId': kOrderId,
          }).status,
          OrderStatus.pending,
        );
      });
    });
  });

  group('toJson', () {
    test('emits the exact camelCase keys expected by the backend', () {
      final json = buildDriverOrderDetailsDto().toJson();

      expect(json.keys.toSet(), {
        'orderId',
        'orderNumber',
        'status',
        'isGift',
        'totalPrice',
        'currency',
        'paymentMethod',
        'notes',
        'pickup',
        'userAddress',
        'recipientInfo',
        'items',
        'timeline',
      });
    });

    test('emits the scalar field values unchanged', () {
      final json = buildDriverOrderDetailsDto().toJson();

      expect(json['orderId'], kOrderId);
      expect(json['orderNumber'], 'ORD-12345');
      expect(json['status'], 'picked_up');
      expect(json['isGift'], isTrue);
      expect(json['totalPrice'], 3000.0);
      expect(json['currency'], 'EGP');
      expect(json['paymentMethod'], 'COD');
      expect(json['notes'], 'Handle flowers with care');
    });

    test('embeds the nested DTO instances instead of nested maps', () {
      final dto = buildDriverOrderDetailsDto();

      final json = dto.toJson();

      expect(json['pickup'], same(dto.pickupAddress));
      expect(json['userAddress'], same(dto.userAddress));
      expect(json['recipientInfo'], same(dto.recipientInfo));
      expect(json['items'], same(dto.items));
      expect(json['timeline'], same(dto.timeline));
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

    test('round-trips every status through fromJson', () {
      for (final status in OrderStatus.values) {
        final dto = DriverOrderDetailsDto(status: status);
        final reparsed = DriverOrderDetailsDto.fromJson(dto.toJson());

        expect(reparsed.status, status, reason: 'status ${status.name}');
      }
    });
  });

  group('toDomain', () {
    test('maps the live payload onto a renderable entity', () {
      final entity = DriverOrderDetailsDto.fromJson(
        realDriverOrderDetailsResponse(),
      ).toDomain();

      expect(entity.orderId, kRealOrderId);
      expect(entity.orderNumber, '');
      expect(entity.status, OrderStatus.pending);
      expect(entity.totalPrice, isNull);
      expect(entity.currency, '');
      expect(entity.paymentMethod, '');
      expect(entity.notes, '');

      expect(entity.pickupAddress.storeName, 'Unknown Store');
      expect(entity.pickupAddress.addressLine, 'Store Location');
      expect(entity.pickupAddress.latitude, 0);
      expect(entity.pickupAddress.longitude, 0);

      expect(entity.userAddress.recipientName, 'Sarah Ahmed');
      expect(entity.userAddress.phone, '+201001234567');
      expect(entity.userAddress.addressLine, '45 El-Nahr Street, Apartment 4B');
      expect(entity.userAddress.latitude, 29.9602);
      expect(entity.userAddress.longitude, 31.2569);

      expect(entity.items, hasLength(2));
      expect(entity.items.first.productName, 'Glass Flower Vase');
      expect(entity.items.first.quantity, 1);
      expect(entity.items.first.unitPrice, isNull);
      expect(entity.timeline, isEmpty);
    });

    test('derives recipient info from isGift and the user address', () {
      final entity = DriverOrderDetailsDto.fromJson(
        realDriverOrderDetailsResponse(),
      ).toDomain();

      expect(entity.recipientInfo.isGift, isFalse);
      expect(entity.recipientInfo.recipientName, 'Sarah Ahmed');
      expect(entity.recipientInfo.recipientPhone, '+201001234567');
    });

    test('prefers explicit recipient info over the derived one', () {
      final entity = buildDriverOrderDetailsDto().toDomain();

      expect(entity.recipientInfo.isGift, isTrue);
      expect(entity.recipientInfo.recipientName, 'Sara');
      expect(entity.recipientInfo.recipientPhone, '+201012345678');
    });

    test('maps every scalar field onto the entity', () {
      final entity = buildDriverOrderDetailsDto().toDomain();

      expect(entity.orderId, kOrderId);
      expect(entity.orderNumber, 'ORD-12345');
      expect(entity.status, OrderStatus.pickedUp);
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
    });

    test('converts every item in the list', () {
      final entity = buildDriverOrderDetailsDto().toDomain();

      expect(entity.items, hasLength(1));
      expect(
        entity.items.first.productId,
        '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      );
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
      final entity = buildDriverOrderDetailsDto(
        notes: 'Leave at door',
      ).toDomain();

      expect(entity.notes, 'Leave at door');
    });

    test('builds empty addresses and lists for a minimal payload', () {
      final entity = DriverOrderDetailsDto.fromJson(
        const <String, dynamic>{},
      ).toDomain();

      expect(entity.orderId, '');
      expect(entity.pickupAddress.storeName, '');
      expect(entity.pickupAddress.latitude, 0);
      expect(entity.userAddress.recipientName, '');
      expect(entity.items, isEmpty);
      expect(entity.timeline, isEmpty);
      expect(entity.recipientInfo.isGift, isFalse);
    });

    test('does not share the mutable list with the DTO', () {
      final dto = buildDriverOrderDetailsDto();

      dto.toDomain().items.add(buildOrderItemEntity());

      expect(dto.items, hasLength(1));
    });
  });
}
