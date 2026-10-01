import 'package:driver_app/features/order_details/data/dtos/responses/order_item_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/pickup_address_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/recipient_info_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/timeline_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/user_address_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_order_details_response_dto.g.dart';

@JsonSerializable()
class DriverOrderDetailsDto {
  @JsonKey(name: 'orderId')
  final String orderId;

  @JsonKey(name: 'orderNumber')
  final String orderNumber;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'totalPrice')
  final double totalPrice;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'paymentMethod')
  final String paymentMethod;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'pickupAddress')
  final PickupAddressDto pickupAddress;

  @JsonKey(name: 'userAddress')
  final UserAddressDto userAddress;

  @JsonKey(name: 'recipientInfo')
  final RecipientInfoDto recipientInfo;

  @JsonKey(name: 'items')
  final List<OrderItemDto> items;

  @JsonKey(name: 'timeline')
  final List<TimelineDto> timeline;

  DriverOrderDetailsDto({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.totalPrice,
    required this.currency,
    required this.paymentMethod,
    this.notes,
    required this.pickupAddress,
    required this.userAddress,
    required this.recipientInfo,
    required this.items,
    required this.timeline,
  });

  factory DriverOrderDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$DriverOrderDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverOrderDetailsDtoToJson(this);

  DriverOrderDetailsEntity toDomain() => DriverOrderDetailsEntity(
    orderId: orderId,
    orderNumber: orderNumber,
    status: status,
    totalPrice: totalPrice,
    currency: currency,
    paymentMethod: paymentMethod,
    notes: notes ?? '',
    pickupAddress: pickupAddress.toDomain(),
    userAddress: userAddress.toDomain(),
    recipientInfo: recipientInfo.toDomain(),
    items: items.map((item) => item.toDomain()).toList(),
    timeline: timeline.map((entry) => entry.toDomain()).toList(),
  );
}