
import 'package:equatable/equatable.dart';
import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:driver_app/features/order_details/domain/entities/timeline.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';

class DriverOrderDetailsEntity extends Equatable {
  final String orderId;
  final String orderNumber;
  final OrderStatus status;

  /// Order total, or null when the backend did not send one.
  final double? totalPrice;
  final String currency;
  final String paymentMethod;
  final String notes;
  final PickupAddressEntity pickupAddress;
  final UserAddressEntity userAddress;
  final RecipientInfoEntity recipientInfo;
  final List<OrderItemEntity> items;
  final List<TimelineEntity> timeline;

  const DriverOrderDetailsEntity({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.totalPrice,
    required this.currency,
    required this.paymentMethod,
    required this.notes,
    required this.pickupAddress,
    required this.userAddress,
    required this.recipientInfo,
    required this.items,
    required this.timeline,
  });

  DriverOrderDetailsEntity copyWith({
    OrderStatus? status,
    double? totalPrice,
    String? currency,
    List<OrderItemEntity>? items,
  }) => DriverOrderDetailsEntity(
    orderId: orderId,
    orderNumber: orderNumber,
    status: status ?? this.status,
    totalPrice: totalPrice ?? this.totalPrice,
    currency: currency ?? this.currency,
    paymentMethod: paymentMethod,
    notes: notes,
    pickupAddress: pickupAddress,
    userAddress: userAddress,
    recipientInfo: recipientInfo,
    items: items ?? this.items,
    timeline: timeline,
  );

  /// Fills in the prices the driver payload omits using [pricing]. Items whose
  /// `productId` is missing from the pricing response keep their own value so
  /// one item's price is never reused for another.
  DriverOrderDetailsEntity withPricing(OrderPricingEntity? pricing) {
    if (pricing == null) return this;

    final prices = pricing.unitPriceByProductId;
    final mergedItems = items
        .map(
          (item) => prices[item.productId] == null
              ? item
              : item.copyWith(unitPrice: prices[item.productId]),
        )
        .toList(growable: false);

    return copyWith(
      totalPrice: pricing.total,
      currency: currency.trim().isNotEmpty ? currency : pricing.currency,
      items: mergedItems,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        status,
        totalPrice,
        currency,
        paymentMethod,
        notes,
        pickupAddress,
        userAddress,
        recipientInfo,
        items,
        timeline,
      ];
}
