import 'package:driver_app/features/order_details/data/dtos/responses/order_item_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/pickup_address_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/recipient_info_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/timeline_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/user_address_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_order_details_response_dto.g.dart';

@JsonSerializable()
class DriverOrderDetailsDto {
  @JsonKey(name: 'orderId')
  final String orderId;

  @JsonKey(name: 'orderNumber')
  final String orderNumber;

  @JsonKey(
    name: 'status',
    fromJson: DriverOrderDetailsDto._statusFromJson,
    toJson: DriverOrderDetailsDto._statusToJson,
  )
  final OrderStatus status;

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

  static OrderStatus _statusFromJson(dynamic value) {
    final normalized = value
        .toString()
        .replaceAll(RegExp(r'[\s_-]+'), '')
        .toLowerCase();

    switch (normalized) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'assigned':
        return OrderStatus.assigned;
      case 'ontheway':
        return OrderStatus.onTheWay;
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'arrived':
        return OrderStatus.arrived;
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'picked':
        return OrderStatus.picked;
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToJson(OrderStatus value) {
    switch (value) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.assigned:
        return 'assigned';
      case OrderStatus.onTheWay:
        return 'on_the_way';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.arrived:
        return 'arrived';
      case OrderStatus.pickedUp:
        return 'picked_up';
      case OrderStatus.picked:
        return 'picked';
    }
  }

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
