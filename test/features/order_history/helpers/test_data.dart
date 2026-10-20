import 'package:driver_app/features/order_history/data/model/catalog_api_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_api_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_details_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_history_list_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_history_request_dto.dart';
import 'package:driver_app/features/order_history/data/model/product_response_dto.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/entities/pagination_entities.dart';

// --- DTO Builders ---

LocationDto createLocationDto({
  double lat = 30.0,
  double lng = 31.0,
}) {
  return LocationDto(lat: lat, lng: lng);
}

OrderPickupDto createOrderPickupDto({
  String storeName = 'Flowery Store',
  LocationDto? location,
  String address = '123 Flower St',
  String? imageUrl = 'http://example.com/store.png',
}) {
  return OrderPickupDto(
    storeName: storeName,
    location: location ?? createLocationDto(),
    address: address,
    imageUrl: imageUrl,
  );
}

OrderUserAddressDto createOrderUserAddressDto({
  String recipientName = 'John Doe',
  String recipientPhone = '+201234567890',
  LocationDto? location,
  String address = '456 User St',
  String? imageUrl = 'http://example.com/user.png',
}) {
  return OrderUserAddressDto(
    recipientName: recipientName,
    recipientPhone: recipientPhone,
    location: location ?? createLocationDto(),
    address: address,
    imageUrl: imageUrl,
  );
}

OrderDetailsItemDto createOrderDetailsItemDto({
  String productId = 'p1',
  String productName = 'Red Roses',
  int quantity = 2,
}) {
  return OrderDetailsItemDto(
    productId: productId,
    productName: productName,
    quantity: quantity,
  );
}

OrderDetailsResponseDto createOrderDetailsResponseDto({
  String orderId = 'order123',
  String status = 'delivered',
  bool isGift = false,
  List<OrderDetailsItemDto>? items,
  OrderPickupDto? pickup,
  OrderUserAddressDto? userAddress,
}) {
  return OrderDetailsResponseDto(
    orderId: orderId,
    status: status,
    isGift: isGift,
    items: items ?? [createOrderDetailsItemDto()],
    pickup: pickup ?? createOrderPickupDto(),
    userAddress: userAddress ?? createOrderUserAddressDto(),
  );
}

OrderHistoryStoreDto createOrderHistoryStoreDto({
  String name = 'Flowery Store',
  String address = '123 Flower St',
  String? imageUrl = 'http://example.com/store.png',
}) {
  return OrderHistoryStoreDto(
    name: name,
    address: address,
    imageUrl: imageUrl,
  );
}

OrderHistoryRecipientDto createOrderHistoryRecipientDto({
  String name = 'John Doe',
  String city = 'Giza',
  String area = 'Zayed',
  String? imageUrl = 'http://example.com/user.png',
}) {
  return OrderHistoryRecipientDto(
    name: name,
    city: city,
    area: area,
    imageUrl: imageUrl,
  );
}

OrderHistoryItemDto createOrderHistoryItemDto({
  String orderId = 'order123',
  String status = 'delivered',
  OrderHistoryStoreDto? store,
  OrderHistoryRecipientDto? recipient,
  int itemCount = 3,
  double total = 150.0,
  DateTime? estimatedDeliveryAt,
  DateTime? deliveredAt,
  DateTime? assignedAt,
}) {
  return OrderHistoryItemDto(
    orderId: orderId,
    status: status,
    store: store ?? createOrderHistoryStoreDto(),
    recipient: recipient ?? createOrderHistoryRecipientDto(),
    itemCount: itemCount,
    total: total,
    estimatedDeliveryAt: estimatedDeliveryAt,
    deliveredAt: deliveredAt ?? DateTime(2024, 9, 3, 11, 0),
    assignedAt: assignedAt ?? DateTime(2024, 9, 3, 10, 0),
  );
}

PaginationDto createPaginationDto({
  int page = 1,
  int pageSize = 10,
  int totalCount = 1,
  int totalPages = 1,
  bool hasNextPage = false,
  bool hasPreviousPage = false,
}) {
  return PaginationDto(
    page: page,
    pageSize: pageSize,
    totalCount: totalCount,
    totalPages: totalPages,
    hasNextPage: hasNextPage,
    hasPreviousPage: hasPreviousPage,
  );
}

OrderHistoryResponseDto createOrderHistoryResponseDto({
  List<OrderHistoryItemDto>? items,
  PaginationDto? pagination,
}) {
  return OrderHistoryResponseDto(
    items: items ?? [createOrderHistoryItemDto()],
    pagination: pagination ?? createPaginationDto(),
  );
}

ProductIncludeDto createProductIncludeDto({String name = 'Vase'}) {
  return ProductIncludeDto(name: name);
}

ProductResponseDto createProductResponseDto({
  String id = 'p1',
  String name = 'Red Roses',
  String imageUrl = 'http://example.com/rose.png',
  String currency = 'EGP',
  double price = 100.0,
  double originalPrice = 120.0,
  double discountPercentage = 16.6,
  String status = 'in_stock',
  List<String>? images,
  String description = 'Beautiful red roses',
  List<ProductIncludeDto>? includes,
}) {
  return ProductResponseDto(
    id: id,
    name: name,
    imageUrl: imageUrl,
    currency: currency,
    price: price,
    originalPrice: originalPrice,
    discountPercentage: discountPercentage,
    status: status,
    images: images ?? ['http://example.com/rose.png'],
    description: description,
    includes: includes ?? [createProductIncludeDto()],
  );
}

OrderHistoryRequestDto createOrderHistoryRequestDto({
  int page = 1,
  int pageSize = 10,
}) {
  return OrderHistoryRequestDto(page: page, pageSize: pageSize);
}

OrderApiResponseDto<T> createOrderApiResponseDto<T>({
  bool success = true,
  String message = 'Success',
  T? data,
  Object? error,
}) {
  return OrderApiResponseDto<T>(
    success: success,
    message: message,
    data: data,
    error: error,
  );
}

CatalogApiResponseDto<T> createCatalogApiResponseDto<T>({
  bool isSuccess = true,
  String message = 'Success',
  String statusCode = '200',
  T? data,
}) {
  return CatalogApiResponseDto<T>(
    isSuccess: isSuccess,
    message: message,
    statusCode: statusCode,
    data: data,
  );
}

// --- Entity Builders ---

OrderStoreEntity createOrderStoreEntity({
  String name = 'Flowery Store',
  String address = '123 Flower St',
  String? imageUrl = 'http://example.com/store.png',
}) {
  return OrderStoreEntity(
    name: name,
    address: address,
    imageUrl: imageUrl,
  );
}

OrderUserEntity createOrderUserEntity({
  String name = 'John Doe',
  String address = 'Zayed, Giza',
  String? imageUrl = 'http://example.com/user.png',
}) {
  return OrderUserEntity(
    name: name,
    address: address,
    imageUrl: imageUrl,
  );
}

OrderHistoryEntity createOrderHistoryEntity({
  String orderId = 'order123',
  OrderStatus status = OrderStatus.completed,
  OrderStoreEntity? store,
  OrderUserEntity? user,
  int itemCount = 3,
  double total = 150.0,
  DateTime? assignedAt,
  DateTime? estimatedDeliveryAt,
  DateTime? deliveredAt,
}) {
  return OrderHistoryEntity(
    orderId: orderId,
    status: status,
    store: store ?? createOrderStoreEntity(),
    user: user ?? createOrderUserEntity(),
    itemCount: itemCount,
    total: total,
    assignedAt: assignedAt ?? DateTime(2024, 9, 3, 10, 0),
    estimatedDeliveryAt: estimatedDeliveryAt,
    deliveredAt: deliveredAt ?? DateTime(2024, 9, 3, 11, 0),
  );
}

PaginationEntity createPaginationEntity({
  int page = 1,
  int pageSize = 10,
  int totalCount = 1,
  int totalPages = 1,
  bool hasNextPage = false,
  bool hasPreviousPage = false,
}) {
  return PaginationEntity(
    page: page,
    pageSize: pageSize,
    totalCount: totalCount,
    totalPages: totalPages,
    hasNextPage: hasNextPage,
    hasPreviousPage: hasPreviousPage,
  );
}

PaginatedEntity<T> createPaginatedEntity<T>({
  List<T>? items,
  PaginationEntity? pagination,
}) {
  return PaginatedEntity<T>(
    items: items ?? [],
    pagination: pagination ?? createPaginationEntity(),
  );
}

OrderProductEntity createOrderProductEntity({
  String id = 'p1',
  String name = 'Red Roses',
  String imageUrl = 'http://example.com/rose.png',
  String currency = 'EGP',
  double price = 100.0,
}) {
  return OrderProductEntity(
    id: id,
    name: name,
    imageUrl: imageUrl,
    currency: currency,
    price: price,
  );
}

OrderItemEntity createOrderItemEntity({
  String productId = 'p1',
  int quantity = 2,
  OrderProductEntity? product,
}) {
  return OrderItemEntity(
    productId: productId,
    quantity: quantity,
    product: product ?? createOrderProductEntity(),
  );
}

OrderHistoryDetailsEntity createOrderHistoryDetailsEntity({
  String orderId = 'order123',
  OrderStatus status = OrderStatus.completed,
  OrderStoreEntity? store,
  OrderUserEntity? user,
  List<OrderItemEntity>? items,
  bool isCashOnDelivery = true,
}) {
  return OrderHistoryDetailsEntity(
    orderId: orderId,
    status: status,
    store: store ?? createOrderStoreEntity(),
    user: user ?? createOrderUserEntity(),
    items: items ?? [createOrderItemEntity()],
    isCashOnDelivery: isCashOnDelivery,
  );
}

// --- JSON Fixtures ---

Map<String, dynamic> get ordersListResponseJson => {
      'items': [
        {
          'orderId': 'order123',
          'status': 'delivered',
          'store': {
            'name': 'Flowery Store',
            'address': '123 Flower St',
            'imageUrl': 'http://example.com/store.png',
          },
          'recipient': {
            'name': 'John Doe',
            'city': 'Giza',
            'area': 'Zayed',
            'imageUrl': 'http://example.com/user.png',
          },
          'itemCount': 3,
          'total': 150.0,
          'assignedAt': '2024-09-03T10:00:00.000Z',
          'deliveredAt': '2024-09-03T11:00:00.000Z',
        }
      ],
      'pagination': {
        'page': 1,
        'pageSize': 10,
        'totalCount': 1,
        'totalPages': 1,
        'hasNextPage': false,
        'hasPreviousPage': false,
      }
    };

Map<String, dynamic> get orderDetailsResponseJson => {
      'orderId': 'order123',
      'status': 'delivered',
      'isGift': false,
      'items': [
        {
          'productId': 'p1',
          'productName': 'Red Roses',
          'quantity': 2,
        }
      ],
      'pickup': {
        'storeName': 'Flowery Store',
        'location': {'lat': 30.0, 'lng': 31.0},
        'address': '123 Flower St',
        'imageUrl': 'http://example.com/store.png',
      },
      'userAddress': {
        'recipientName': 'John Doe',
        'recipientPhone': '+201234567890',
        'location': {'lat': 30.0, 'lng': 31.0},
        'address': '456 User St',
        'imageUrl': 'http://example.com/user.png',
      }
    };

Map<String, dynamic> get productResponseJson => {
      'id': 'p1',
      'name': 'Red Roses',
      'imageUrl': 'http://example.com/rose.png',
      'currency': 'EGP',
      'price': 100.0,
      'originalPrice': 120.0,
      'discountPercentage': 16.6,
      'status': 'in_stock',
      'images': ['http://example.com/rose.png'],
      'description': 'Beautiful red roses',
      'includes': [
        {'name': 'Vase'}
      ],
    };

Map<String, dynamic> orderApiResponseJson(
  Map<String, dynamic>? data, {
  bool success = true,
  String message = 'Success',
}) =>
    {
      'success': success,
      'message': message,
      'data': data,
      'error': null,
    };

Map<String, dynamic> catalogApiResponseJson(
  Map<String, dynamic>? data, {
  bool isSuccess = true,
  String message = 'Success',
  String statusCode = '200',
}) =>
    {
      'isSuccess': isSuccess,
      'message': message,
      'statusCode': statusCode,
      'data': data,
    };
