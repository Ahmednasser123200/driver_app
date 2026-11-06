import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:equatable/equatable.dart';

class DeliveryMapArgs extends Equatable {
  final AddressModel pickupAddress;
  final AddressModel userAddress;
  final DeliveryMapTarget? initialTarget;

  const DeliveryMapArgs({
    required this.pickupAddress,
    required this.userAddress,
    this.initialTarget,
  });

  @override
  List<Object?> get props => [pickupAddress, userAddress, initialTarget];
}
