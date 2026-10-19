import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/utils/excecute_api_call.dart';
import 'package:driver_app/features/order_details/data/datasources/order_details_remote_data_source.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/order_pricing_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';
import 'package:injectable/injectable.dart';

import '../../client/order_details_api_client.dart';

@Injectable(as: OrderDetailsRemoteDataSource)
class OrderDetailsRemoteDataSourceImpl implements OrderDetailsRemoteDataSource {
  OrderDetailsRemoteDataSourceImpl(this._apiClient);

  final OrderDetailsApiClient _apiClient;

  @override
  Future<BaseResponse<DriverOrderDetailsDto>> getOrderDetails(String orderId) =>
      excecuteApiCall(() => _apiClient.getOrderDetails(orderId));

  @override
  Future<BaseResponse<OrderPricingDto>> getOrderPricing(String orderId) =>
      excecuteApiCall(() => _apiClient.getOrderPricing(orderId));

  @override
  Future<BaseResponse<ReportDriverLocationResponseDto>> reportDriverLocation(
    ReportDriverLocationRequestDto requestDto,
  ) => excecuteApiCall(() => _apiClient.reportDriverLocation(requestDto));

  @override
  Future<BaseResponse<UpdateOrderStatusResponseDto>> updateOrderStatus(
    UpdateOrderStatusRequestDto requestDto,
    String orderId,
  ) => excecuteApiCall(() => _apiClient.updateOrderStatus(orderId, requestDto));
}
