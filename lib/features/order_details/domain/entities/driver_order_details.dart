import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:driver_app/features/order_details/domain/entities/timeline.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';

class DriverOrderDetailsEntity {
  final String orderId;
  final String orderNumber;
  final String status;
  final double totalPrice;
  final String currency;
  final String paymentMethod;
  final String notes;
  final PickupAddressEntity pickupAddress;
  final UserAddressEntity userAddress;
  final RecipientInfoEntity recipientInfo;
  final List<OrderItemEntity> items;
  final List<TimelineEntity> timeline;

  DriverOrderDetailsEntity({
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
}