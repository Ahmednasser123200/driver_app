import 'package:driver_app/features/order_details/data/dtos/responses/recipient_info_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'isGift': true,
    'recipientName': 'Sara',
    'recipientPhone': '+201012345678',
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = RecipientInfoDto.fromJson(json());

      expect(dto.isGift, isTrue);
      expect(dto.recipientName, 'Sara');
      expect(dto.recipientPhone, '+201012345678');
    });

    test('parses isGift as a bool', () {
      final dto = RecipientInfoDto.fromJson(json()..['isGift'] = false);

      expect(dto.isGift, isFalse);
    });

    test('accepts an empty recipient name', () {
      final dto = RecipientInfoDto.fromJson(json()..['recipientName'] = '');

      expect(dto.recipientName, '');
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildRecipientInfoDto().toJson().keys.toSet(),
        {'isGift', 'recipientName', 'recipientPhone'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildRecipientInfoDto();

      expect(
        RecipientInfoDto.fromJson(original.toJson()).toJson(),
        original.toJson(),
      );
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildRecipientInfoDto().toDomain();

      expect(entity.isGift, isTrue);
      expect(entity.recipientName, 'Sara');
      expect(entity.recipientPhone, '+201012345678');
    });

    test('keeps a false gift flag', () {
      final entity = RecipientInfoDto.fromJson(json()..['isGift'] = false)
          .toDomain();

      expect(entity.isGift, isFalse);
    });
  });
}