import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_history_entities.dart';
import '../../domain/entities/pagination_entities.dart';

part 'order_history_list_response_dto.g.dart';

OrderStatus? orderStatusFromApi(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return null;
  }
}

@JsonSerializable()
class OrderHistoryResponseDto {
  @JsonKey(name: 'items')
  final List<OrderHistoryItemDto> items;
  @JsonKey(name: 'pagination')
  final PaginationDto pagination;

  const OrderHistoryResponseDto({
    required this.items,
    required this.pagination,
  });

  factory OrderHistoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryResponseDtoToJson(this);

  PaginatedEntity<OrderHistoryEntity> toEntity() {
    return PaginatedEntity(
      items: items
          .map((item) => item.toEntityOrNull())
          .whereType<OrderHistoryEntity>()
          .toList(),
      pagination: pagination.toEntity(),
    );
  }
}

@JsonSerializable()
class PaginationDto {
  @JsonKey(name: 'page')
  final int page;
  @JsonKey(name: 'pageSize')
  final int pageSize;
  @JsonKey(name: 'totalCount')
  final int totalCount;
  @JsonKey(name: 'totalPages')
  final int totalPages;
  @JsonKey(name: 'hasNextPage')
  final bool hasNextPage;
  @JsonKey(name: 'hasPreviousPage')
  final bool hasPreviousPage;

  const PaginationDto({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);

  PaginationEntity toEntity() {
    return PaginationEntity(
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }
}

@JsonSerializable()
class OrderHistoryItemDto {
  @JsonKey(name: 'orderId')
  final String orderId;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'store')
  final OrderHistoryStoreDto store;
  @JsonKey(name: 'recipient')
  final OrderHistoryRecipientDto recipient;
  @JsonKey(name: 'itemCount')
  final int itemCount;
  @JsonKey(name: 'total')
  final double total;
  @JsonKey(name: 'estimatedDeliveryAt')
  final DateTime? estimatedDeliveryAt;
  @JsonKey(name: 'deliveredAt')
  final DateTime? deliveredAt;
  @JsonKey(name: 'assignedAt')
  final DateTime assignedAt;

  const OrderHistoryItemDto({
    required this.orderId,
    required this.status,
    required this.store,
    required this.recipient,
    required this.itemCount,
    required this.total,
    this.estimatedDeliveryAt,
    this.deliveredAt,
    required this.assignedAt,
  });

  factory OrderHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryItemDtoToJson(this);

  OrderHistoryEntity? toEntityOrNull() {
    final orderStatus = orderStatusFromApi(status);
    if (orderStatus == null) return null;

    return OrderHistoryEntity(
      orderId: orderId,
      status: orderStatus,
      store: store.toEntity(),
      user: recipient.toEntity(),
      itemCount: itemCount,
      total: total,
      assignedAt: assignedAt,
      estimatedDeliveryAt: estimatedDeliveryAt,
      deliveredAt: deliveredAt,
    );
  }
}

@JsonSerializable()
class OrderHistoryStoreDto {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'address')
  final String address;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  const OrderHistoryStoreDto({
    required this.name,
    required this.address,
    this.imageUrl,
  });

  factory OrderHistoryStoreDto.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryStoreDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryStoreDtoToJson(this);

  OrderStoreEntity toEntity() {
    return OrderStoreEntity(
      name: name,
      address: address,
      imageUrl: imageUrl,
    );
  }
}

@JsonSerializable()
class OrderHistoryRecipientDto {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'city')
  final String city;
  @JsonKey(name: 'area')
  final String area;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  const OrderHistoryRecipientDto({
    required this.name,
    required this.city,
    required this.area,
    this.imageUrl,
  });

  factory OrderHistoryRecipientDto.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryRecipientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryRecipientDtoToJson(this);

  OrderUserEntity toEntity() {
    return OrderUserEntity(
      name: name,
      address: [area, city].where((part) => part.isNotEmpty).join(', '),
      imageUrl: imageUrl,
    );
  }
}
