import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/domain/repo/home_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: HomeRepo)
class HomeRepoImpl implements HomeRepo {
final  HomeRemoteDataSource homeRemoteDataSource;

  HomeRepoImpl(this.homeRemoteDataSource);
  @override
  Future<BaseResponse<void>> acceptOrder(String orderId) async {
    return _execureRepCall<void, void>(
      () => homeRemoteDataSource.acceptOrder(orderId),
      (data) => data,
    );
    // var response = await homeRemoteDataSource.acceptOrder(orderId);
    // switch (response) {
    //   case Success<void>():
    //     return Success<void>(response.data);
    //   case Error<void>():
    //     return Error<void>(response.failure);
    // }
  }

  @override
  Future<BaseResponse<AvailableOrders>> getAvailableOrders({
    int page = 1,
  }) async {
    return _execureRepCall<AvailableOrdersResponseDto, AvailableOrders>(
      () => homeRemoteDataSource.getAvailableOrders(page: page),
      (data) => data.toDomain(),
    );
    // return await _executeRepoCall(homeRemoteDataSource.getAvailableOrders);
    // var resonse = await homeRemoteDataSource.getAvailableOrders();
    // switch (resonse) {
    //   case Success<AvailableOrdersResponseDto>():
    //     return Success<AvailableOrders>(resonse.data.toDomain());
    //   case Error<AvailableOrdersResponseDto>():
    //     return Error<AvailableOrders>(resonse.failure);
    // }
  }

  Future<BaseResponse<R>> _execureRepCall<T, R>(
    Future<BaseResponse<T>> Function() request,
    R Function(T data) mapper,
  ) async {
    var response = await request();
    switch (response) {
      case Success<T>():
        return Success<R>(mapper(response.data));
      case Error<T>():
        return Error<R>(response.failure);
    }
  }
}
