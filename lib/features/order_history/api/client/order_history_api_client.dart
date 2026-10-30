import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_strings/api_strings.dart';
import '../../data/model/api_envelopes.dart';
import '../../data/model/order_details_response_dto.dart';
import '../../data/model/order_history_list_response_dto.dart';
import '../../data/model/product_response_dto.dart';

part 'order_history_api_client.g.dart';

@singleton
@RestApi()
abstract class OrderHistoryApiClient {
  @factoryMethod
  factory OrderHistoryApiClient(Dio dio) = _OrderHistoryApiClient;

  @GET(ApiStrings.driverOrders)
  Future<OrderApiResponseDto<OrderHistoryResponseDto>> getOrders(
      @Queries() Map<String, dynamic> queries,
      );

  @GET(ApiStrings.driverOrderDetails)
  Future<OrderApiResponseDto<OrderDetailsResponseDto>> getOrderDetails(
      @Path(ApiStrings.orderIdKey) String orderId,
      );

  @GET(ApiStrings.catalogProduct)
  Future<CatalogApiResponseDto<ProductResponseDto>> getProduct(
      @Path(ApiStrings.productIdKey) String productId,
      );
}