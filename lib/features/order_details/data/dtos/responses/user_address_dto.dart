import 'package:driver_app/features/order_details/data/dtos/responses/location_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_address_dto.g.dart';

/// Mirrors the `userAddress` object of the driver order response:
/// `{"recipientName": "...", "recipientPhone": "...",
///   "location": {"lat": 0, "lng": 0}, "address": "..."}`.
@JsonSerializable()
class UserAddressDto {
  @JsonKey(name: 'recipientName')
  final String? recipientName;

  @JsonKey(name: 'recipientPhone')
  final String? phone;

  @JsonKey(name: 'address')
  final String? addressLine;

  @JsonKey(name: 'location')
  final LocationDto? location;

  UserAddressDto({
    this.recipientName,
    this.phone,
    this.addressLine,
    this.location,
  });

  factory UserAddressDto.fromJson(Map<String, dynamic> json) =>
      _$UserAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserAddressDtoToJson(this);

  UserAddressEntity toDomain() => UserAddressEntity(
    recipientName: recipientName ?? '',
    phone: phone ?? '',
    addressLine: addressLine ?? '',
    latitude: location?.lat ?? 0,
    longitude: location?.lng ?? 0,
  );
}
