import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';

abstract class OrderDetailsRepo {
  Future<BaseResponse<DriverOrderDetailsEntity>> getOrderDetails(String orderId);

  Future<BaseResponse<ReportDriverLocationEntity>> reportDriverLocation(
    ReportDriverLocationRequestDto requestDto,
  );

  Future<BaseResponse<UpdateOrderStatusEntity>> updateOrderStatus(
    UpdateOrderStatusRequestDto requestDto,
    String orderId,
  );
}