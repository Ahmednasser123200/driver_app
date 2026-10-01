import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_address_dto.g.dart';

@JsonSerializable()
class UserAddressDto {
  @JsonKey(name: 'recipientName')
  final String recipientName;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'addressLine')
  final String addressLine;

  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  UserAddressDto({
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
  });

  factory UserAddressDto.fromJson(Map<String, dynamic> json) =>
      _$UserAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserAddressDtoToJson(this);

  UserAddressEntity toDomain() => UserAddressEntity(
    recipientName: recipientName,
    phone: phone,
    addressLine: addressLine,
    latitude: latitude,
    longitude: longitude,
  );
}