import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';

abstract class OrderDetailsRemoteDataSource {
  Future<BaseResponse<DriverOrderDetailsDto>> getOrderDetails(String orderId);
  Future<BaseResponse<ReportDriverLocationResponseDto>> reportDriverLocation(
    ReportDriverLocationRequestDto requestDto,
  );
  Future<BaseResponse<UpdateOrderStatusResponseDto>> updateOrderStatus(
    UpdateOrderStatusRequestDto requestDto,
    String orderId,
  );
}
