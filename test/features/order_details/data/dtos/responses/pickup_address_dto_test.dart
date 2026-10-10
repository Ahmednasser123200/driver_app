import 'package:driver_app/features/order_details/data/dtos/responses/pickup_address_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'storeName': 'Flowery store',
    'addressLine': '20th st, Sheikh Zayed, Giza',
    'latitude': 30.0511,
    'longitude': 31.3656,
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = PickupAddressDto.fromJson(json());

      expect(dto.storeName, 'Flowery store');
      expect(dto.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.latitude, 30.0511);
      expect(dto.longitude, 31.3656);
    });

    test('coerces integer coordinates into doubles', () {
      final dto = PickupAddressDto.fromJson(
        json()
          ..['latitude'] = 30
          ..['longitude'] = 31,
      );

      expect(dto.latitude, 30.0);
      expect(dto.longitude, 31.0);
    });

    test('accepts negative coordinates', () {
      final dto = PickupAddressDto.fromJson(
        json()
          ..['latitude'] = -33.8688
          ..['longitude'] = -151.2093,
      );

      expect(dto.latitude, -33.8688);
      expect(dto.longitude, -151.2093);
    });

    test('accepts a zero coordinate', () {
      expect(PickupAddressDto.fromJson(json()..['latitude'] = 0).latitude, 0.0);
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildPickupAddressDto().toJson().keys.toSet(),
        {'storeName', 'addressLine', 'latitude', 'longitude'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildPickupAddressDto();

      expect(
        PickupAddressDto.fromJson(original.toJson()).toJson(),
        original.toJson(),
      );
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildPickupAddressDto().toDomain();

      expect(entity.storeName, 'Flowery store');
      expect(entity.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(entity.latitude, 30.0511);
      expect(entity.longitude, 31.3656);
    });
  });
}