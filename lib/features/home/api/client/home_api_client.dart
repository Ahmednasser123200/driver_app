import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'home_api_client.g.dart';

@singleton
@RestApi()
abstract class HomeApiClient {
  @factoryMethod
  factory HomeApiClient(Dio dio) = _HomeApiClient;

  @GET(ApiStrings.availableOrders)
  Future<AvailableOrdersResponseDto> getAvailableOrders({
   
    @Query(AppStrings.page) int page = 1,
    @Query(AppStrings.pageSize) int pageSize = 10,
  });

  @POST(ApiStrings.acceptOrder)
  Future<void> acceptOrder(

    @Path(AppStrings.orderrId) String orderId,
  );
}
