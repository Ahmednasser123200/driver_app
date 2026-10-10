import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/data/datasources/order_details_remote_data_source.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:injectable/injectable.dart';

import '../../domain/params/update_order_status_params.dart';
import '../../domain/repo/order_details_repo.dart';

@LazySingleton(as: OrderDetailsRepo)
class OrderDetailsRepoImpl implements OrderDetailsRepo {
  OrderDetailsRepoImpl(this._remoteDataSource);

  final OrderDetailsRemoteDataSource _remoteDataSource;

  @override
  Future<BaseResponse<DriverOrderDetailsEntity>> getOrderDetails(
    String orderId,
  ) => _mapResponse(
    () => _remoteDataSource.getOrderDetails(orderId),
    (response) => response.toDomain(),
  );

  @override
  Future<BaseResponse<ReportDriverLocationEntity>> reportDriverLocation(
    ReportDriverLocationParams params,
  ) => _mapResponse(
    () => _remoteDataSource.reportDriverLocation(
      ReportDriverLocationRequestDto(
        lat: params.lat,
        lng: params.lng,
        recordedAt: params.recordedAt,
      ),
    ),
    (response) => response.toDomain(),
  );

  @override
  Future<BaseResponse<UpdateOrderStatusEntity>> updateOrderStatus(
    UpdateOrderStatusParams params,
  ) => _mapResponse(
    () => _remoteDataSource.updateOrderStatus(
      UpdateOrderStatusRequestDto(newStatus: params.newStatus),
      params.orderId,
    ),
    (response) => response.toDomain(),
  );

  Future<BaseResponse<TDomain>> _mapResponse<TResponse, TDomain>(
    Future<BaseResponse<TResponse>> Function() request,
    TDomain Function(TResponse) toDomain,
  ) async {
    final response = await request();
    return switch (response) {
      Success<TResponse>(data: final data) => Success<TDomain>(toDomain(data)),
      Error<TResponse>(failure: final failure) => Error<TDomain>(failure),
    };
  }
}