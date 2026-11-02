
import 'package:equatable/equatable.dart';
import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:driver_app/features/order_details/domain/entities/timeline.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';

class DriverOrderDetailsEntity extends Equatable {
  final String orderId;
  final String orderNumber;
  final OrderStatus status;
  final double totalPrice;
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
