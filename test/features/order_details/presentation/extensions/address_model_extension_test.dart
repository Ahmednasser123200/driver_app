import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:driver_app/features/order_details/presentation/extensions/address_model_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressModelExtension', () {
    test('PickupAddressEntity.toAddressModel maps fields accurately', () {
      const entity = PickupAddressEntity(
        storeName: 'Flowery Flowers',
        addressLine: '15 Nile Corniche, Maadi',
        latitude: 29.9553,
        longitude: 31.2612,
      );

      final model = entity.toAddressModel();

      expect(model.title, 'Flowery Flowers');
      expect(model.addressLine, '15 Nile Corniche, Maadi');
      expect(model.latitude, 29.9553);
      expect(model.longitude, 31.2612);
      expect(model.phoneNumber, isNull);
    });

    test('UserAddressEntity.toAddressModel maps fields accurately', () {
      const entity = UserAddressEntity(
        recipientName: 'Ahmed Ali',
        phone: '+201098765432',
        addressLine: 'Apt 4B, Zamalek, Cairo',
        latitude: 30.0626,
        longitude: 31.2197,
      );

      final model = entity.toAddressModel();

      expect(model.title, 'Ahmed Ali');
      expect(model.addressLine, 'Apt 4B, Zamalek, Cairo');
      expect(model.latitude, 30.0626);
      expect(model.longitude, 31.2197);
      expect(model.phoneNumber, '+201098765432');
    });
  });
}
