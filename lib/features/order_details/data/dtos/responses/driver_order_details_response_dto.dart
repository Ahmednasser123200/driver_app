import 'package:driver_app/features/order_details/data/dtos/responses/order_item_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/pickup_address_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/recipient_info_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/timeline_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/user_address_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_order_details_response_dto.g.dart';

/// Response of `GET /order/drivers/me/orders/{orderId}` (the
/// `active-order` endpoint answers with the same shape).
///
/// The API is wrapped in a `{success, message, data, error}` envelope and only
/// guarantees `orderId`, `status`, `isGift`, `items`, `pickup` and
/// `userAddress`. Every other field the driver screen renders is optional, so
/// they stay nullable here and are defaulted in [toDomain] instead of making
/// deserialization throw (which surfaced as the generic "Something went wrong").
@JsonSerializable()
class DriverOrderDetailsDto {
  @JsonKey(name: 'orderId')
  final String? orderId;

  @JsonKey(name: 'orderNumber')
  final String? orderNumber;

  @JsonKey(
    name: 'status',
    fromJson: DriverOrderDetailsDto._statusFromJson,
    toJson: DriverOrderDetailsDto._statusToJson,
  )
  final OrderStatus status;

  @JsonKey(name: 'isGift')
  final bool? isGift;

  @JsonKey(name: 'totalPrice')
  final double? totalPrice;

  @JsonKey(name: 'currency')
  final String? currency;

  @JsonKey(name: 'paymentMethod')
  final String? paymentMethod;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'pickup')
  final PickupAddressDto? pickupAddress;

  @JsonKey(name: 'userAddress')
  final UserAddressDto? userAddress;

  @JsonKey(name: 'recipientInfo')
  final RecipientInfoDto? recipientInfo;

  @JsonKey(name: 'items')
  final List<OrderItemDto>? items;

  @JsonKey(name: 'timeline')
  final List<TimelineDto>? timeline;

  DriverOrderDetailsDto({
    this.orderId,
    this.orderNumber,
    required this.status,
    this.isGift,
    this.totalPrice,
    this.currency,
    this.paymentMethod,
    this.notes,
    this.pickupAddress,
    this.userAddress,
    this.recipientInfo,
    this.items,
    this.timeline,
  });

  /// Maps the backend `OrderStatus` strings
  /// (`Placed, PendingPayment, PaymentFailed, Preparing, PickedUp,
  /// OutForDelivery, AwaitingDeliveryConfirmation, Delivered, Cancelled`) onto
  /// the statuses the driver screen knows about. Unknown values fall back to
  /// [OrderStatus.pending] instead of failing.
  static OrderStatus _statusFromJson(dynamic value) {
    final normalized = value
        .toString()
        .replaceAll(RegExp(r'[\s_-]+'), '')
        .toLowerCase();

    switch (normalized) {
      case 'placed':
      case 'pendingpayment':
      case 'paymentfailed':
      case 'preparing':
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
      case 'awaitingdeliveryconfirmation':
      case 'arrived':
        return OrderStatus.arrived;
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'picked':
        return OrderStatus.picked;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
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
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  factory DriverOrderDetailsDto.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'];
    final orderJson = responseData is Map
        ? Map<String, dynamic>.from(responseData)
        : Map<String, dynamic>.from(json);
    return _$DriverOrderDetailsDtoFromJson(orderJson);
  }

  Map<String, dynamic> toJson() => _$DriverOrderDetailsDtoToJson(this);

  DriverOrderDetailsEntity toDomain() {
    final address = userAddress;

    return DriverOrderDetailsEntity(
      orderId: orderId ?? '',
      orderNumber: orderNumber ?? '',
      status: status,
      // Kept null when absent so the UI never shows a fabricated 0.00.
      totalPrice: totalPrice,
      currency: currency ?? '',
      paymentMethod: paymentMethod ?? '',
      notes: notes ?? '',
      pickupAddress: (pickupAddress ?? PickupAddressDto()).toDomain(),
      userAddress: (address ?? UserAddressDto()).toDomain(),
      recipientInfo:
          recipientInfo?.toDomain() ??
          RecipientInfoEntity(
            isGift: isGift ?? false,
            recipientName: address?.recipientName ?? '',
            recipientPhone: address?.phone ?? '',
          ),
      items: items?.map((item) => item.toDomain()).toList() ?? const [],
      timeline: timeline?.map((entry) => entry.toDomain()).toList() ?? const [],
    );
  }
}
