import 'package:driver_app/features/order_details/data/dtos/responses/location_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/pickup_address_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'storeName': 'Flowery store',
    'address': '20th st, Sheikh Zayed, Giza',
    'location': <String, dynamic>{'lat': 30.0511, 'lng': 31.3656},
  };

  group('fromJson', () {
    test('parses the shape the driver order endpoint sends', () {
      final dto = PickupAddressDto.fromJson(json());

      expect(dto.storeName, 'Flowery store');
      expect(dto.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.location?.lat, 30.0511);
      expect(dto.location?.lng, 31.3656);
    });

    test('coerces integer coordinates into doubles', () {
      final dto = PickupAddressDto.fromJson(
        json()..['location'] = <String, dynamic>{'lat': 30, 'lng': 31},
      );

      expect(dto.location?.lat, 30.0);
      expect(dto.location?.lng, 31.0);
    });

    test('accepts the zero coordinates the live payload sends', () {
      final dto = PickupAddressDto.fromJson(
        json()..['location'] = <String, dynamic>{'lat': 0, 'lng': 0},
      );

      expect(dto.location?.lat, 0.0);
      expect(dto.location?.lng, 0.0);
    });

    test('accepts negative coordinates', () {
      final dto = PickupAddressDto.fromJson(
        json()
          ..['location'] = <String, dynamic>{'lat': -33.8688, 'lng': -151.2093},
      );

      expect(dto.location?.lat, -33.8688);
      expect(dto.location?.lng, -151.2093);
    });

    test('tolerates a missing location object', () {
      final dto = PickupAddressDto.fromJson(json()..remove('location'));

      expect(dto.location, isNull);
      expect(dto.storeName, 'Flowery store');
    });

    test('tolerates a completely empty payload', () {
      expect(
        PickupAddressDto.fromJson(
          const <String, dynamic>{},
        ).toDomain().storeName,
        '',
      );
    });

    test('parses the store phone when the backend starts sending it', () {
      final dto = PickupAddressDto.fromJson(
        json()..['phone'] = '+201234567890',
      );

      expect(dto.phone, '+201234567890');
      expect(dto.toDomain().phone, '+201234567890');
    });

    test('leaves the store phone empty when it is absent', () {
      final dto = PickupAddressDto.fromJson(json());

      expect(dto.phone, isNull);
      expect(dto.toDomain().phone, '');
    });
  });

  group('toJson', () {
    test('emits the keys the backend uses', () {
      expect(buildPickupAddressDto().toJson().keys.toSet(), {
        'storeName',
        'address',
        'location',
        'phone',
      });
    });

    test('round-trips through fromJson', () {
      final original = buildPickupAddressDto(phone: '+201234567890');

      final reparsed = PickupAddressDto.fromJson(<String, dynamic>{
        'storeName': original.storeName,
        'address': original.addressLine,
        'location': original.location?.toJson(),
        'phone': original.phone,
      });

      expect(reparsed.storeName, original.storeName);
      expect(reparsed.addressLine, original.addressLine);
      expect(reparsed.location?.toJson(), original.location?.toJson());
      expect(reparsed.phone, original.phone);
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildPickupAddressDto(phone: '+201234567890').toDomain();

      expect(entity.storeName, 'Flowery store');
      expect(entity.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(entity.latitude, 30.0511);
      expect(entity.longitude, 31.3656);
      expect(entity.phone, '+201234567890');
    });

    test('falls back to empty values when the payload is incomplete', () {
      final entity = PickupAddressDto(
        storeName: null,
        location: LocationDto(),
      ).toDomain();

      expect(entity.storeName, '');
      expect(entity.addressLine, '');
      expect(entity.latitude, 0);
      expect(entity.longitude, 0);
      expect(entity.phone, '');
    });
  });
}
