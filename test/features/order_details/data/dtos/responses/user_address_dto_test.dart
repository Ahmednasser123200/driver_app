import 'package:driver_app/features/order_details/data/dtos/responses/user_address_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'recipientName': 'Nour Mohamed',
    'phone': '+201012345678',
    'addressLine': '20th st, Sheikh Zayed, Giza',
    'latitude': 30.0444,
    'longitude': 31.2357,
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = UserAddressDto.fromJson(json());

      expect(dto.recipientName, 'Nour Mohamed');
      expect(dto.phone, '+201012345678');
      expect(dto.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.latitude, 30.0444);
      expect(dto.longitude, 31.2357);
    });

    test('rejects a numeric phone value instead of coercing it', () {
      expect(
        () => UserAddressDto.fromJson(json()..['phone'] = 201012345678),
        throwsA(isA<TypeError>()),
      );
    });

    test('coerces integer coordinates into doubles', () {
      final dto = UserAddressDto.fromJson(
        json()
          ..['latitude'] = 30
          ..['longitude'] = 31,
      );

      expect(dto.latitude, 30.0);
      expect(dto.longitude, 31.0);
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildUserAddressDto().toJson().keys.toSet(),
        {'recipientName', 'phone', 'addressLine', 'latitude', 'longitude'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildUserAddressDto();

      expect(
        UserAddressDto.fromJson(original.toJson()).toJson(),
        original.toJson(),
      );
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildUserAddressDto().toDomain();

      expect(entity.recipientName, 'Nour Mohamed');
      expect(entity.phone, '+201012345678');
      expect(entity.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(entity.latitude, 30.0444);
      expect(entity.longitude, 31.2357);
    });
  });
}