// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderHistoryResponseDto _$OrderHistoryResponseDtoFromJson(
  Map<String, dynamic> json,
) => OrderHistoryResponseDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderHistoryItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$OrderHistoryResponseDtoToJson(
  OrderHistoryResponseDto instance,
) => <String, dynamic>{
  'items': instance.items,
  'pagination': instance.pagination,
};

PaginationDto _$PaginationDtoFromJson(Map<String, dynamic> json) =>
    PaginationDto(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );

Map<String, dynamic> _$PaginationDtoToJson(PaginationDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
      'hasNextPage': instance.hasNextPage,
      'hasPreviousPage': instance.hasPreviousPage,
    };

OrderHistoryItemDto _$OrderHistoryItemDtoFromJson(Map<String, dynamic> json) =>
    OrderHistoryItemDto(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      store: OrderHistoryStoreDto.fromJson(
        json['store'] as Map<String, dynamic>,
      ),
      recipient: OrderHistoryRecipientDto.fromJson(
        json['recipient'] as Map<String, dynamic>,
      ),
      itemCount: (json['itemCount'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      estimatedDeliveryAt: json['estimatedDeliveryAt'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );

Map<String, dynamic> _$OrderHistoryItemDtoToJson(
  OrderHistoryItemDto instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'status': instance.status,
  'store': instance.store,
  'recipient': instance.recipient,
  'itemCount': instance.itemCount,
  'total': instance.total,
  'estimatedDeliveryAt': instance.estimatedDeliveryAt?.toIso8601String(),
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'assignedAt': instance.assignedAt.toIso8601String(),
};

OrderHistoryStoreDto _$OrderHistoryStoreDtoFromJson(
  Map<String, dynamic> json,
) => OrderHistoryStoreDto(
  name: json['name'] as String,
  address: json['address'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$OrderHistoryStoreDtoToJson(
  OrderHistoryStoreDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'imageUrl': instance.imageUrl,
};

OrderHistoryRecipientDto _$OrderHistoryRecipientDtoFromJson(
  Map<String, dynamic> json,
) => OrderHistoryRecipientDto(
  name: json['name'] as String,
  city: json['city'] as String,
  area: json['area'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$OrderHistoryRecipientDtoToJson(
  OrderHistoryRecipientDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'city': instance.city,
  'area': instance.area,
  'imageUrl': instance.imageUrl,
};
