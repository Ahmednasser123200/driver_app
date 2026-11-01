import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryMapTarget', () {
    test('pickup properties', () {
      const target = DeliveryMapTarget.pickup;
      expect(target.isPickup, isTrue);
      expect(target.isUser, isFalse);
    });

    test('user properties', () {
      const target = DeliveryMapTarget.user;
      expect(target.isPickup, isFalse);
      expect(target.isUser, isTrue);
    });
  });
}
