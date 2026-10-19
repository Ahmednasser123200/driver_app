import 'package:driver_app/features/order_details/data/dtos/responses/location_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pickup_address_dto.g.dart';

/// Mirrors the `pickup` object of the driver order response:
/// `{"storeName": "...", "location": {"lat": 0, "lng": 0}, "address": "..."}`.
///
/// `phone` is not sent by the backend today; it is parsed when present so the
/// store's call/WhatsApp actions start working as soon as it is added.
@JsonSerializable()
class PickupAddressDto {
  @JsonKey(name: 'storeName')
  final String? storeName;

  @JsonKey(name: 'address')
  final String? addressLine;

  @JsonKey(name: 'location')
  final LocationDto? location;

  @JsonKey(name: 'phone')
  final String? phone;

  PickupAddressDto({
    this.storeName,
    this.addressLine,
    this.location,
    this.phone,
  });

  factory PickupAddressDto.fromJson(Map<String, dynamic> json) =>
      _$PickupAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PickupAddressDtoToJson(this);

  PickupAddressEntity toDomain() => PickupAddressEntity(
    storeName: storeName ?? '',
    addressLine: addressLine ?? '',
    latitude: location?.lat ?? 0,
    longitude: location?.lng ?? 0,
    phone: phone ?? '',
  );
}
