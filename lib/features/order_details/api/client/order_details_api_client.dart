import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/report_driver_location_response_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

part 'order_details_api_client.g.dart';

@singleton
@RestApi()
abstract class OrderDetailsApiClient {
  @factoryMethod
  factory OrderDetailsApiClient(Dio dio, {String? baseUrl}) =
      _OrderDetailsApiClient;

  @GET(ApiStrings.driverOrderDetailsRoute)
  Future<DriverOrderDetailsDto> getOrderDetails(
    @Path('orderId') String orderId,
  );

  @PATCH(ApiStrings.updateOrderStatusRoute)
  Future<UpdateOrderStatusResponseDto> updateOrderStatus(
    @Path('orderId') String orderId,
    @Body() UpdateOrderStatusRequestDto request,
  );

  @POST(ApiStrings.reportDriverLocation)
  Future<ReportDriverLocationResponseDto> reportDriverLocation(
    @Body() ReportDriverLocationRequestDto request,
  );
}
