class AddressModel {
  final String title;
  final String addressLine;
  final double latitude;
  final double longitude;
  final String? phoneNumber;

  const AddressModel({
    required this.title,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
  });

  AddressModel copyWith({
    String? title,
    String? addressLine,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    bool clearPhoneNumber = false,
  }) {
    return AddressModel(
      title: title ?? this.title,
      addressLine: addressLine ?? this.addressLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber:
          clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          addressLine == other.addressLine &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => Object.hash(
    title,
    addressLine,
    latitude,
    longitude,
    phoneNumber,
  );

  @override
  String toString() =>
      'AddressModel(title: $title, addressLine: $addressLine, lat: $latitude, lng: $longitude, phone: $phoneNumber)';
}
