import 'package:driver_app/features/order_details/data/dtos/responses/location_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pickup_address_dto.g.dart';

/// Mirrors the `pickup` object of the driver order response:
/// `{"storeName": "...", "location": {"lat": 0, "lng": 0}, "address": "..."}`.
@JsonSerializable()
class PickupAddressDto {
  @JsonKey(name: 'storeName')
  final String? storeName;

  @JsonKey(name: 'address')
  final String? addressLine;

  @JsonKey(name: 'location')
  final LocationDto? location;

  PickupAddressDto({this.storeName, this.addressLine, this.location});

  factory PickupAddressDto.fromJson(Map<String, dynamic> json) =>
      _$PickupAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PickupAddressDtoToJson(this);

  PickupAddressEntity toDomain() => PickupAddressEntity(
    storeName: storeName ?? '',
    addressLine: addressLine ?? '',
    latitude: location?.lat ?? 0,
    longitude: location?.lng ?? 0,
  );
}
