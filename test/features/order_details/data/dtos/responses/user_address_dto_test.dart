import 'package:driver_app/features/order_details/data/dtos/responses/location_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/user_address_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'recipientName': 'Nour Mohamed',
    'recipientPhone': '+201012345678',
    'address': '20th st, Sheikh Zayed, Giza',
    'location': <String, dynamic>{'lat': 30.0444, 'lng': 31.2357},
  };

  group('fromJson', () {
    test('parses the shape the driver order endpoint sends', () {
      final dto = UserAddressDto.fromJson(json());

      expect(dto.recipientName, 'Nour Mohamed');
      expect(dto.phone, '+201012345678');
      expect(dto.addressLine, '20th st, Sheikh Zayed, Giza');
      expect(dto.location?.lat, 30.0444);
      expect(dto.location?.lng, 31.2357);
    });

    test('rejects a numeric phone value instead of coercing it', () {
      expect(
        () =>
            UserAddressDto.fromJson(json()..['recipientPhone'] = 201012345678),
        throwsA(isA<TypeError>()),
      );
    });

    test('coerces integer coordinates into doubles', () {
      final dto = UserAddressDto.fromJson(
        json()..['location'] = <String, dynamic>{'lat': 30, 'lng': 31},
      );

      expect(dto.location?.lat, 30.0);
      expect(dto.location?.lng, 31.0);
    });

    test('tolerates a missing location object', () {
      final dto = UserAddressDto.fromJson(json()..remove('location'));

      expect(dto.location, isNull);
      expect(dto.recipientName, 'Nour Mohamed');
    });
  });

  group('toJson', () {
    test('emits the keys the backend uses', () {
      expect(buildUserAddressDto().toJson().keys.toSet(), {
        'recipientName',
        'recipientPhone',
        'address',
        'location',
      });
    });

    test('round-trips through fromJson', () {
      final original = buildUserAddressDto();

      final reparsed = UserAddressDto.fromJson(<String, dynamic>{
        'recipientName': original.recipientName,
        'recipientPhone': original.phone,
        'address': original.addressLine,
        'location': original.location?.toJson(),
      });

      expect(reparsed.recipientName, original.recipientName);
      expect(reparsed.phone, original.phone);
      expect(reparsed.addressLine, original.addressLine);
      expect(reparsed.location?.toJson(), original.location?.toJson());
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

    test('falls back to empty values when the payload is incomplete', () {
      final entity = UserAddressDto(location: LocationDto()).toDomain();

      expect(entity.recipientName, '');
      expect(entity.phone, '');
      expect(entity.addressLine, '');
      expect(entity.latitude, 0);
      expect(entity.longitude, 0);
    });
  });
}
