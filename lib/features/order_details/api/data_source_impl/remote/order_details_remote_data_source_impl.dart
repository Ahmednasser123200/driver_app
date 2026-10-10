import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/data/datasources/order_details_remote_data_source.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';
import 'package:injectable/injectable.dart';

import '../../client/order_details_api_client.dart';

@LazySingleton(as: OrderDetailsRemoteDataSource)
class OrderDetailsRemoteDataSourceImpl implements OrderDetailsRemoteDataSource {
  OrderDetailsRemoteDataSourceImpl(this._apiClient);

  final OrderDetailsApiClient _apiClient;

  @override
  Future<BaseResponse<DriverOrderDetailsDto>> getOrderDetails(String orderId) =>
      _execute(() => _apiClient.getOrderDetails(orderId));

  @override
  Future<BaseResponse<ReportDriverLocationResponseDto>> reportDriverLocation(
    ReportDriverLocationRequestDto requestDto,
  ) => _execute(() => _apiClient.reportDriverLocation(requestDto));

  @override
  Future<BaseResponse<UpdateOrderStatusResponseDto>> updateOrderStatus(
    UpdateOrderStatusRequestDto requestDto,
    String orderId,
  ) => _execute(() => _apiClient.updateOrderStatus(orderId, requestDto));

  
Future<BaseResponse<T>> _execute<T>(
  Future<T> Function() request,
) async {
  try {
    return Success<T>(await request());
  } on DioException catch (error) {
    return Error<T>(mapDioExceptionToAppFailure(error));
 } catch (error) {
  return Error<T>(const UnknownFailure());
}
}


}
