import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';

import '../params/update_order_status_params.dart';

abstract class OrderDetailsRepo {
  Future<BaseResponse<DriverOrderDetailsEntity>> getOrderDetails(
    String orderId,
  );

  Future<BaseResponse<ReportDriverLocationEntity>> reportDriverLocation(
    ReportDriverLocationParams params,
  );

  Future<BaseResponse<UpdateOrderStatusEntity>> updateOrderStatus(
    UpdateOrderStatusParams params,
  );
}
