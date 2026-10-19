import 'package:equatable/equatable.dart';

class PickupAddressEntity extends Equatable {
  final String storeName;
  final String addressLine;
  final double latitude;
  final double longitude;

  /// Store contact number, or an empty string when the backend does not send
  /// one. It is never filled with the recipient's number or a guess.
  final String phone;

  const PickupAddressEntity({
    required this.storeName,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    this.phone = '',
  });

  @override
  List<Object?> get props => [
    storeName,
    addressLine,
    latitude,
    longitude,
    phone,
  ];
}
