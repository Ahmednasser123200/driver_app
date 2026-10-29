import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressModel', () {
    const model = AddressModel(
      title: 'Flowery Store',
      addressLine: '123 Main St, Cairo',
      latitude: 30.0444,
      longitude: 31.2357,
      phoneNumber: '+201012345678',
    );

    test('constructor assigns all fields correctly', () {
      expect(model.title, 'Flowery Store');
      expect(model.addressLine, '123 Main St, Cairo');
      expect(model.latitude, 30.0444);
      expect(model.longitude, 31.2357);
      expect(model.phoneNumber, '+201012345678');
    });

    test('copyWith preserves existing fields when none provided', () {
      final copy = model.copyWith();

      expect(copy.title, model.title);
      expect(copy.addressLine, model.addressLine);
      expect(copy.latitude, model.latitude);
      expect(copy.longitude, model.longitude);
      expect(copy.phoneNumber, model.phoneNumber);
      expect(copy, equals(model));
    });

    test('copyWith updates specified fields correctly', () {
      final updated = model.copyWith(
        title: 'New Store',
        addressLine: '456 Secondary St',
        latitude: 31.1234,
        longitude: 30.5678,
        phoneNumber: '+201099998888',
      );

      expect(updated.title, 'New Store');
      expect(updated.addressLine, '456 Secondary St');
      expect(updated.latitude, 31.1234);
      expect(updated.longitude, 30.5678);
      expect(updated.phoneNumber, '+201099998888');
    });

    test('copyWith clears phone number when clearPhoneNumber is true', () {
      final cleared = model.copyWith(clearPhoneNumber: true);

      expect(cleared.phoneNumber, isNull);
      expect(cleared.title, model.title);
    });

    test('equality and hashCode support value equality', () {
      const identicalModel = AddressModel(
        title: 'Flowery Store',
        addressLine: '123 Main St, Cairo',
        latitude: 30.0444,
        longitude: 31.2357,
        phoneNumber: '+201012345678',
      );

      const differentTitle = AddressModel(
        title: 'Other',
        addressLine: '123 Main St, Cairo',
        latitude: 30.0444,
        longitude: 31.2357,
        phoneNumber: '+201012345678',
      );

      const differentAddress = AddressModel(
        title: 'Flowery Store',
        addressLine: 'Different',
        latitude: 30.0444,
        longitude: 31.2357,
        phoneNumber: '+201012345678',
      );

      const differentLat = AddressModel(
        title: 'Flowery Store',
        addressLine: '123 Main St, Cairo',
        latitude: 10.0,
        longitude: 31.2357,
        phoneNumber: '+201012345678',
      );

      const differentLng = AddressModel(
        title: 'Flowery Store',
        addressLine: '123 Main St, Cairo',
        latitude: 30.0444,
        longitude: 10.0,
        phoneNumber: '+201012345678',
      );

      const differentPhone = AddressModel(
        title: 'Flowery Store',
        addressLine: '123 Main St, Cairo',
        latitude: 30.0444,
        longitude: 31.2357,
        phoneNumber: '+201111111111',
      );

      expect(model, equals(identicalModel));
      expect(model.hashCode, equals(identicalModel.hashCode));
      expect(model == model, isTrue);
      expect(model == Object(), isFalse);
      expect(model, isNot(equals(differentTitle)));
      expect(model, isNot(equals(differentAddress)));
      expect(model, isNot(equals(differentLat)));
      expect(model, isNot(equals(differentLng)));
      expect(model, isNot(equals(differentPhone)));
    });

    test('toString returns human readable description', () {
      final str = model.toString();

      expect(str, contains('Flowery Store'));
      expect(str, contains('123 Main St, Cairo'));
      expect(str, contains('30.0444'));
      expect(str, contains('31.2357'));
    });
  });
}
