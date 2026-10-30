import 'package:injectable/injectable.dart';

import '../../../../config/base/base_response.dart';
import '../../../../config/errors/app_failure.dart';
import '../../domain/entities/order_history_entities.dart';
import '../../domain/entities/pagination_entities.dart';
import '../../domain/repo/order_history_repo.dart';
import '../data_source/order_history_remote_data_source.dart';
import '../model/order_details_response_dto.dart';
import '../model/order_history_request_dto.dart';
import '../model/product_response_dto.dart';

@Injectable(as: OrderHistoryRepo)
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
    final loaded = await _loadItems(order.items);
    if (loaded is! Success<List<OrderItemEntity>>) {
      return Error((loaded as Error<List<OrderItemEntity>>).failure);
    }
    final entity = order.toEntityOrNull(loaded.data);
    if (entity == null) return Error(const UnexpectedStatusFailure());
    return Success(entity);
  }

  Future<BaseResponse<List<OrderItemEntity>>> _loadItems(
      List<OrderDetailsItemDto> items,
      ) async {
    final responses = await Future.wait(
      items.map((item) => _remoteDataSource.getProduct(item.productId)),
    );
    final loaded = <OrderItemEntity>[];
    for (var i = 0; i < items.length; i++) {
      final response = responses[i];
      if (response is! Success<ProductResponseDto>) {
        return Error((response as Error<ProductResponseDto>).failure);
      }
      loaded.add(
        OrderItemEntity(
          productId: items[i].productId,
          quantity: items[i].quantity,
          product: response.data.toEntity(),
        ),
      );
    }
    return Success(loaded);
  }
  @override
  Stream<BaseResponse<OrderHistoryEntity>> watchOrderUpdates() {
    return const Stream.empty();
  }
}