
import 'package:equatable/equatable.dart';

class UserAddressEntity extends Equatable {
  final String recipientName;
  final String phone;
  final String addressLine;
  final double latitude;
  final double longitude;

  const UserAddressEntity({
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        recipientName,
        phone,
        addressLine,
        latitude,
        longitude,
      ];
}
