import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/utils/excecute_api_call.dart';
import 'package:driver_app/features/home/api/client/home_api_client.dart';
import 'package:driver_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final HomeApiClient apiClient;
  HomeRemoteDataSourceImpl(this.apiClient);
  @override
  Future<BaseResponse<AvailableOrdersResponseDto>> getAvailableOrders({
    int page = 1,
  }) async {
    return excecuteApiCall(() => apiClient.getAvailableOrders(page: page));
  }

  @override
  Future<BaseResponse<void>> acceptOrder(String orderId) async {
    return excecuteApiCall(() => apiClient.acceptOrder(orderId));
  }
}
