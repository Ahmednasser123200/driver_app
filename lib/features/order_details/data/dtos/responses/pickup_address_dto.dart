import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pickup_address_dto.g.dart';

@JsonSerializable()
class PickupAddressDto {
  @JsonKey(name: 'storeName')
  final String storeName;

  @JsonKey(name: 'addressLine')
  final String addressLine;

  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  PickupAddressDto({
    required this.storeName,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
  });

  factory PickupAddressDto.fromJson(Map<String, dynamic> json) =>
      _$PickupAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PickupAddressDtoToJson(this);

  PickupAddressEntity toDomain() => PickupAddressEntity(
    storeName: storeName,
    addressLine: addressLine,
    latitude: latitude,
    longitude: longitude,
  );
}