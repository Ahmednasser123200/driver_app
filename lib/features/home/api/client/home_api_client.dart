import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
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
    // @Header('Authorization')
    // String token =
    //     'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMWExMTE5YS01MTRmLTdlMzAtOGViMi0zOGM0ODJjNzkzNTciLCJlbWFpbCI6InNheWVkMkBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJEcml2ZXIiLCJleHAiOjE3OTEzMDczNzMsImlzcyI6IkZsb3dlcnNBdXRoIiwiYXVkIjoiRmxvd2Vyc0FwcCJ9.twmsGaxsgTPcqzeQGCYIb28ETxKtAxWhv3buBv6mlJA',
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 10,
  });

  @POST(ApiStrings.acceptOrder)
  Future<void> acceptOrder(
    // @Header('Authorization')
    // String token2 =
    //     'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMWExMTE5YS01MTRmLTdlMzAtOGViMi0zOGM0ODJjNzkzNTciLCJlbWFpbCI6InNheWVkMkBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJEcml2ZXIiLCJleHAiOjE3OTEzMDczNzMsImlzcyI6IkZsb3dlcnNBdXRoIiwiYXVkIjoiRmxvd2Vyc0FwcCJ9.twmsGaxsgTPcqzeQGCYIb28ETxKtAxWhv3buBv6mlJA',
    @Path("orderId") String orderId,
  );
}
