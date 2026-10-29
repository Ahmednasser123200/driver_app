import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';

extension PickupAddressEntityToAddressModelX on PickupAddressEntity {
  AddressModel toAddressModel() => AddressModel(
    title: storeName,
    addressLine: addressLine,
    latitude: latitude,
    longitude: longitude,
  );
}

extension UserAddressEntityToAddressModelX on UserAddressEntity {
  AddressModel toAddressModel() => AddressModel(
    title: recipientName,
    addressLine: addressLine,
    latitude: latitude,
    longitude: longitude,
    phoneNumber: phone,
  );
}
