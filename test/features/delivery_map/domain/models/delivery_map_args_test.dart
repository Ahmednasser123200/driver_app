import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_args.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryMapArgs', () {
    const pickup = AddressModel(
      title: 'Flowery store',
      addressLine: '20th st, Sheikh Zayed, Giza',
      latitude: 30.0131,
      longitude: 31.2089,
    );
    const user = AddressModel(
      title: 'Nour mohamed',
      addressLine: '20th st, Sheikh Zayed, Giza',
      latitude: 30.0250,
      longitude: 31.2200,
    );

    test('supports value equality and props', () {
      const args1 = DeliveryMapArgs(
        pickupAddress: pickup,
        userAddress: user,
        initialTarget: DeliveryMapTarget.pickup,
      );
      const args2 = DeliveryMapArgs(
        pickupAddress: pickup,
        userAddress: user,
        initialTarget: DeliveryMapTarget.pickup,
      );
      const args3 = DeliveryMapArgs(
        pickupAddress: pickup,
        userAddress: user,
        initialTarget: DeliveryMapTarget.user,
      );

      expect(args1, equals(args2));
      expect(args1.props, equals(args2.props));
      expect(args1, isNot(equals(args3)));
    });
  });
}
