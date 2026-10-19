

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base/base_response.dart';
import '../../../../config/dio/dio_failure_mapper.dart';
import '../../../../config/errors/app_failure.dart';
import '../../data/data_source/order_history_remote_data_source.dart';
import '../../data/model/catalog_api_response_dto.dart';
import '../../data/model/order_api_response_dto.dart';
import '../../data/model/order_details_response_dto.dart';
import '../../data/model/order_history_list_response_dto.dart';
import '../../data/model/order_history_request_dto.dart';
import '../../data/model/product_response_dto.dart';
import '../client/order_history_api_client.dart';

@LazySingleton(as: OrderHistoryRemoteDataSource)
class OrderHistoryRemoteDataSourceImpl implements OrderHistoryRemoteDataSource {
  final OrderHistoryApiClient _client;

  OrderHistoryRemoteDataSourceImpl(this._client);

  @override
  Future<BaseResponse<OrderHistoryResponseDto>> getOrders(
      OrderHistoryRequestDto request,
      ) {
    return _execute(() async {
      final response = await _client.getOrders(request.toJson());
      return _fromOrderEnvelope(response);
    });
  }

  @override
  Future<BaseResponse<OrderDetailsResponseDto>> getOrderDetails(
      String orderId,
      ) {
    return _execute(() async {
      final response = await _client.getOrderDetails(orderId);
      return _fromOrderEnvelope(response);
    });
  }

  @override
  Future<BaseResponse<ProductResponseDto>> getProduct(String productId) {
    return _execute(() async {
      final response = await _client.getProduct(productId);
      return _fromCatalogEnvelope(response);
    });
  }

  Future<BaseResponse<T>> _execute<T>(
      Future<BaseResponse<T>> Function() call,
      ) async {
    try {
      return await call();
    } on DioException catch (e) {
      return Error(mapDioExceptionToAppFailure(e));
    } catch (_) {
      return Error(const UnknownFailure());
    }
  }

  BaseResponse<T> _fromOrderEnvelope<T>(OrderApiResponseDto<T> response) {
    if (!response.success) {
      return Error(BadRequestFailure(serverMessage: response.message));
    }
    final data = response.data;
    if (data == null) return Error(const UnknownFailure());
    return Success(data);
  }

  BaseResponse<T> _fromCatalogEnvelope<T>(CatalogApiResponseDto<T> response) {
    if (!response.isSuccess) {
      return Error(BadRequestFailure(serverMessage: response.message));
    }
    final data = response.data;
    if (data == null) return Error(const UnknownFailure());
    return Success(data);
  }
}