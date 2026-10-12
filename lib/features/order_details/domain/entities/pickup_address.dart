
import 'package:equatable/equatable.dart';

class PickupAddressEntity extends Equatable {
  final String storeName;
  final String addressLine;
  final double latitude;
  final double longitude;

  const PickupAddressEntity({
    required this.storeName,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        storeName,
        addressLine,
        latitude,
        longitude,
      ];
}