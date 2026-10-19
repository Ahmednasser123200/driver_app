import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/order_history_entities.dart';
import '../../domain/entities/pagination_entities.dart';
import '../../domain/repo/order_history_repo.dart';
import '../data_source/order_history_remote_data_source.dart';
import '../model/order_details_response_dto.dart';
import '../model/order_history_request_dto.dart';
import '../model/product_response_dto.dart';

@LazySingleton(as: OrderHistoryRepo)
class OrderHistoryRepoImpl implements OrderHistoryRepo {
  final OrderHistoryRemoteDataSource _remoteDataSource;

  OrderHistoryRepoImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<PaginatedEntity<OrderHistoryEntity>>> getOrders({
    required int page,
    required int pageSize,
  }) async {
    final response = await _remoteDataSource.getOrders(
      OrderHistoryRequestDto(page: page, pageSize: pageSize),
    );
    return switch (response) {
      Success(:final data) => Success(data.toEntity()),
      Error(:final failure) => Error(failure),
    };
  }

  @override
  Future<BaseResponse<OrderHistoryDetailsEntity>> getOrderDetails({
    required String orderId,
  }) async {
    final response = await _remoteDataSource.getOrderDetails(orderId);
    return switch (response) {
      Success(:final data) => await _buildDetails(data),
      Error(:final failure) => Error(failure),
    };
  }

  Future<BaseResponse<OrderHistoryDetailsEntity>> _buildDetails(
      OrderDetailsResponseDto order,
      ) async {
    final items = await _loadItems(order.items);
    final entity = order.toEntityOrNull(items);
    if (entity == null) return Error(const NotFoundFailure());
    return Success(entity);
  }

  Future<List<OrderItemEntity>> _loadItems(
      List<OrderDetailsItemDto> items,
      ) async {
    final responses = await Future.wait(
      items.map((item) => _remoteDataSource.getProduct(item.productId)),
    );
    return [
      for (var i = 0; i < items.length; i++)
        if (responses[i] case Success<ProductResponseDto>(:final data))
          OrderItemEntity(
            productId: items[i].productId,
            quantity: items[i].quantity,
            product: data.toEntity(),
          ),
    ];
  }

  @override
  Stream<BaseResponse<OrderHistoryEntity>> watchOrderUpdates() {
    return const Stream.empty();
  }
}