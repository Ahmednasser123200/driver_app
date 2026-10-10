import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/order_item_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/pickup_address_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/recipient_info_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/timeline_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/user_address_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/pickup_address.dart';
import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/timeline.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/entities/user_address.dart';

const String kOrderId = 'bbbb2222-0002-0002-0002-000000000002';

PickupAddressEntity buildPickupAddressEntity() => PickupAddressEntity(
  storeName: 'Flowery store',
  addressLine: '20th st, Sheikh Zayed, Giza',
  latitude: 30.0511,
  longitude: 31.3656,
);

UserAddressEntity buildUserAddressEntity() => UserAddressEntity(
  recipientName: 'Nour Mohamed',
  phone: '+201012345678',
  addressLine: '20th st, Sheikh Zayed, Giza',
  latitude: 30.0444,
  longitude: 31.2357,
);

RecipientInfoEntity buildRecipientInfoEntity() => RecipientInfoEntity(
  isGift: true,
  recipientName: 'Sara',
  recipientPhone: '+201012345678',
);

OrderItemEntity buildOrderItemEntity({
  String productId = '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  String productName = 'Red Roses Bouquet',
  int quantity = 2,
  double unitPrice = 1500.0,
  String imageUrl = 'https://example.com/rose.png',
}) => OrderItemEntity(
  productId: productId,
  productName: productName,
  quantity: quantity,
  unitPrice: unitPrice,
  imageUrl: imageUrl,
);

TimelineEntity buildTimelineEntity({
  String status = 'Placed',
  String timestamp = '2026-09-19T17:00:00Z',
}) => TimelineEntity(status: status, timestamp: timestamp);

DriverOrderDetailsEntity buildDriverOrderDetailsEntity({
  String orderId = kOrderId,
  String orderNumber = 'ORD-12345',
  String status = 'PickedUp',
  double totalPrice = 3000.0,
  String currency = 'EGP',
  String paymentMethod = 'COD',
  String notes = 'Handle flowers with care',
  PickupAddressEntity? pickupAddress,
  UserAddressEntity? userAddress,
  RecipientInfoEntity? recipientInfo,
  List<OrderItemEntity>? items,
  List<TimelineEntity>? timeline,
}) => DriverOrderDetailsEntity(
  orderId: orderId,
  orderNumber: orderNumber,
  status: status,
  totalPrice: totalPrice,
  currency: currency,
  paymentMethod: paymentMethod,
  notes: notes,
  pickupAddress: pickupAddress ?? buildPickupAddressEntity(),
  userAddress: userAddress ?? buildUserAddressEntity(),
  recipientInfo: recipientInfo ?? buildRecipientInfoEntity(),
  items: items ?? [buildOrderItemEntity()],
  timeline: timeline ?? [buildTimelineEntity()],
);

UpdateOrderStatusEntity buildUpdateOrderStatusEntity() =>
    UpdateOrderStatusEntity(
      orderId: kOrderId,
      status: 'PickedUp',
      updatedAt: '2026-09-19T18:00:00Z',
    );

PickupAddressDto buildPickupAddressDto() => PickupAddressDto(
  storeName: 'Flowery store',
  addressLine: '20th st, Sheikh Zayed, Giza',
  latitude: 30.0511,
  longitude: 31.3656,
);

UserAddressDto buildUserAddressDto() => UserAddressDto(
  recipientName: 'Nour Mohamed',
  phone: '+201012345678',
  addressLine: '20th st, Sheikh Zayed, Giza',
  latitude: 30.0444,
  longitude: 31.2357,
);

RecipientInfoDto buildRecipientInfoDto() => RecipientInfoDto(
  isGift: true,
  recipientName: 'Sara',
  recipientPhone: '+201012345678',
);

OrderItemDto buildOrderItemDto({
  String productId = '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  String productName = 'Red Roses Bouquet',
  int quantity = 2,
  double unitPrice = 1500.0,
  String imageUrl = 'https://example.com/rose.png',
}) => OrderItemDto(
  productId: productId,
  productName: productName,
  quantity: quantity,
  unitPrice: unitPrice,
  imageUrl: imageUrl,
);

TimelineDto buildTimelineDto({
  String status = 'Placed',
  String timestamp = '2026-09-19T17:00:00Z',
}) => TimelineDto(status: status, timestamp: timestamp);

DriverOrderDetailsDto buildDriverOrderDetailsDto({
  String orderId = kOrderId,
  String orderNumber = 'ORD-12345',
  String status = 'PickedUp',
  double totalPrice = 3000.0,
  String currency = 'EGP',
  String paymentMethod = 'COD',
  String? notes = 'Handle flowers with care',
  PickupAddressDto? pickupAddress,
  UserAddressDto? userAddress,
  RecipientInfoDto? recipientInfo,
  List<OrderItemDto>? items,
  List<TimelineDto>? timeline,
}) => DriverOrderDetailsDto(
  orderId: orderId,
  orderNumber: orderNumber,
  status: status,
  totalPrice: totalPrice,
  currency: currency,
  paymentMethod: paymentMethod,
  notes: notes,
  pickupAddress: pickupAddress ?? buildPickupAddressDto(),
  userAddress: userAddress ?? buildUserAddressDto(),
  recipientInfo: recipientInfo ?? buildRecipientInfoDto(),
  items: items ?? [buildOrderItemDto()],
  timeline:
      timeline ??
      [
        buildTimelineDto(),
        buildTimelineDto(
          status: 'PickedUp',
          timestamp: '2026-09-19T17:30:00Z',
        ),
      ],
);

UpdateOrderStatusResponseDto buildUpdateOrderStatusResponseDto() =>
    UpdateOrderStatusResponseDto(
      orderId: kOrderId,
      status: 'PickedUp',
      updatedAt: '2026-09-19T18:00:00Z',
    );

ReportDriverLocationResponseDto buildReportDriverLocationResponseDto() =>
    ReportDriverLocationResponseDto(
      success: true,
      recordedAt: '2026-09-19T18:00:00Z',
    );

ReportDriverLocationEntity buildReportDriverLocationEntity() =>
    ReportDriverLocationEntity(
      success: true,
      recordedAt: '2026-09-19T18:00:00Z',
    );

Map<String, dynamic> driverOrderDetailsJson() {
  final dto = buildDriverOrderDetailsDto();
  final json = dto.toJson()
    ..['pickupAddress'] = dto.pickupAddress.toJson()
    ..['userAddress'] = dto.userAddress.toJson()
    ..['recipientInfo'] = dto.recipientInfo.toJson()
    ..['items'] = dto.items.map((item) => item.toJson()).toList()
    ..['timeline'] = dto.timeline.map((entry) => entry.toJson()).toList();

  return json;
}
