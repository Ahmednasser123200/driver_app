import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/home/api/client/home_api_client.dart';
import 'package:driver_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final  HomeApiClient apiClient;
  HomeRemoteDataSourceImpl(this.apiClient);
  @override
  Future<BaseResponse<AvailableOrdersResponseDto>> getAvailableOrders({
    int page = 1,
  }) async {
    return _excecuteApiCall(() => apiClient.getAvailableOrders(page: page));
    // try {
    //   var response = await apiClient.getAvailableOrders();
    //   return Success<AvailableOrdersResponseDto>(response);
    // } on DioException catch (e) {
    //   return Error<AvailableOrdersResponseDto>(mapDioExceptionToAppFailure(e));
    // } catch (e) {
    //   return Error<AvailableOrdersResponseDto>(const UnknownFailure());
    // }
  }

  @override
  Future<BaseResponse<void>> acceptOrder(String orderId) async {
    return _excecuteApiCall(() => apiClient.acceptOrder(orderId));
    // try {
    //   var response = await apiClient.acceptOrder(orderId);
    //   return Success<void>(response);
    // } on DioException catch (e) {
    //   return Error<void>(mapDioExceptionToAppFailure(e));
    // } catch (e) {
    //   return Error<void>(const UnknownFailure());
    // }
  }

  Future<BaseResponse<T>> _excecuteApiCall<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Success<T>(await request());
    } on DioException catch (e) {
      return Error<T>(mapDioExceptionToAppFailure(e));
    } catch (e, st) {
      debugPrint('REAL ERROR => $e\n$st');
      return Error<T>(const UnknownFailure());
    }
  }
}
