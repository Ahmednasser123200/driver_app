class UserAddressEntity {
  final String recipientName;
  final String phone;
  final String addressLine;
  final double latitude;
  final double longitude;

  UserAddressEntity({
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
  });
}