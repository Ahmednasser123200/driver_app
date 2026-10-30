import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_history_entities.dart';
import 'order_history_list_response_dto.dart' show orderStatusFromApi;

part 'order_details_response_dto.g.dart';

@JsonSerializable()
class OrderDetailsResponseDto {
  @JsonKey(name: 'orderId')
  final String orderId;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'isGift')
  final bool isGift;
  @JsonKey(name: 'items')
  final List<OrderDetailsItemDto> items;
  @JsonKey(name: 'pickup')
  final OrderPickupDto pickup;
  @JsonKey(name: 'userAddress')
  final OrderUserAddressDto userAddress;

  const OrderDetailsResponseDto({
    required this.orderId,
    required this.status,
    required this.isGift,
    required this.items,
    required this.pickup,
    required this.userAddress,
  });

  factory OrderDetailsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsResponseDtoToJson(this);

  OrderHistoryDetailsEntity? toEntityOrNull(List<OrderItemEntity> orderItems) {
    final orderStatus = orderStatusFromApi(status);
    if (orderStatus == null) return null;

    return OrderHistoryDetailsEntity(
      orderId: orderId,
      status: orderStatus,
      store: pickup.toEntity(),
      user: userAddress.toEntity(),
      items: orderItems,
      isCashOnDelivery: !isGift,
    );
  }
}

@JsonSerializable()
class OrderDetailsItemDto {
  @JsonKey(name: 'productId')
  final String productId;
  @JsonKey(name: 'productName')
  final String productName;
  @JsonKey(name: 'quantity')
  final int quantity;

  const OrderDetailsItemDto({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory OrderDetailsItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsItemDtoToJson(this);
}

@JsonSerializable()
class LocationDto {
  @JsonKey(name: 'lat')
  final double lat;
  @JsonKey(name: 'lng')
  final double lng;

  const LocationDto({required this.lat, required this.lng});

  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDtoToJson(this);
}

@JsonSerializable()
class OrderPickupDto {
  @JsonKey(name: 'storeName')
  final String storeName;
  @JsonKey(name: 'location')
  final LocationDto location;
  @JsonKey(name: 'address')
  final String address;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  const OrderPickupDto({
    required this.storeName,
    required this.location,
    required this.address,
    this.imageUrl,
  });

  factory OrderPickupDto.fromJson(Map<String, dynamic> json) =>
      _$OrderPickupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPickupDtoToJson(this);

  OrderStoreEntity toEntity() {
    return OrderStoreEntity(
      name: storeName,
      address: address,
      imageUrl: imageUrl,
    );
  }
}

@JsonSerializable()
class OrderUserAddressDto {
  @JsonKey(name: 'recipientName')
  final String recipientName;
  @JsonKey(name: 'recipientPhone')
  final String recipientPhone;
  @JsonKey(name: 'location')
  final LocationDto location;
  @JsonKey(name: 'address')
  final String address;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  const OrderUserAddressDto({
    required this.recipientName,
    required this.recipientPhone,
    required this.location,
    required this.address,
    this.imageUrl,
  });

  factory OrderUserAddressDto.fromJson(Map<String, dynamic> json) =>
      _$OrderUserAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderUserAddressDtoToJson(this);

  OrderUserEntity toEntity() {
    return OrderUserEntity(
      name: recipientName,
      address: address,
      imageUrl: imageUrl,
    );
  }
}
