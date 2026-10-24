// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter/services.dart' as _i281;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/services/location/geolocator_wrapper.dart' as _i970;
import '../../core/services/location/location_service.dart' as _i898;
import '../../core/services/location/location_service_impl.dart' as _i614;
import '../../features/order_details/api/client/order_details_api_client.dart'
    as _i329;
import '../../features/order_details/api/data_source_impl/remote/order_details_remote_data_source_impl.dart'
    as _i537;
import '../../features/order_details/data/datasources/order_details_remote_data_source.dart'
    as _i702;
import '../../features/order_details/data/repo/order_details_repo_impl.dart'
    as _i692;
import '../../features/order_details/domain/repo/order_details_repo.dart'
    as _i788;
import '../../features/order_details/domain/usecases/get_driver_order_details_use_case.dart'
    as _i837;
import '../../features/order_details/domain/usecases/report_driver_location_use_case.dart'
    as _i59;
import '../../features/order_details/domain/usecases/update_order_status_use_case.dart'
    as _i591;
import '../../features/order_details/presentation/manager/cubit/order_details_cubit.dart'
    as _i841;
import '../../features/pickup_location/api/client/pickup_location_api_client.dart'
    as _i114;
import '../../features/pickup_location/api/data_source_impl/remote/pickup_location_remote_data_source_impl.dart'
    as _i89;
import '../../features/pickup_location/data/datasources/pickup_location_remote_data_source.dart'
    as _i315;
import '../../features/pickup_location/data/repo/pickup_location_repo_impl.dart'
    as _i933;
import '../../features/pickup_location/domain/repo/pickup_location_repo.dart'
    as _i724;
import '../../features/pickup_location/domain/usecases/get_driving_route_use_case.dart'
    as _i1007;
import '../../features/pickup_location/presentation/manager/cubit/pickup_location_cubit.dart'
    as _i719;
import '../dio/auth_interceptor.dart' as _i839;
import '../dio/dio_module.dart' as _i977;
import '../utils/secure_storage_module.dart' as _i327;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final secureStorageModule = _$SecureStorageModule();
    final dioModule = _$DioModule();
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.lazySingleton<_i970.GeolocatorWrapper>(
      () => const _i970.GeolocatorWrapper(),
    );
    gh.lazySingleton<_i839.AuthInterceptors>(
      () => _i839.AuthInterceptors(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i839.AuthInterceptors>()),
    );
    gh.singleton<_i329.OrderDetailsApiClient>(
      () => _i329.OrderDetailsApiClient(gh<_i361.Dio>()),
    );
    gh.singleton<_i114.PickupLocationApiClient>(
      () => _i114.PickupLocationApiClient(gh<_i361.Dio>()),
    );
    gh.factory<_i702.OrderDetailsRemoteDataSource>(
      () => _i537.OrderDetailsRemoteDataSourceImpl(
        gh<_i329.OrderDetailsApiClient>(),
      ),
    );
    gh.factory<_i315.PickupLocationRemoteDataSource>(
      () => _i89.PickupLocationRemoteDataSourceImpl(
        gh<_i114.PickupLocationApiClient>(),
      ),
    );
    gh.factory<_i724.PickupLocationRepo>(
      () => _i933.PickupLocationRepoImpl(
        gh<_i315.PickupLocationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i898.LocationService>(
      () => _i614.LocationServiceImpl(gh<_i970.GeolocatorWrapper>()),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i788.OrderDetailsRepo>(
      () => _i692.OrderDetailsRepoImpl(
        gh<_i702.OrderDetailsRemoteDataSource>(),
        gh<_i898.LocationService>(),
      ),
    );
    gh.factory<_i59.ReportDriverLocationUseCase>(
      () => _i59.ReportDriverLocationUseCase(
        gh<_i788.OrderDetailsRepo>(),
        gh<_i970.GeolocatorWrapper>(),
      ),
    );
    gh.factory<_i837.GetDriverOrderDetailsUseCase>(
      () => _i837.GetDriverOrderDetailsUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i591.UpdateOrderStatusUseCase>(
      () => _i591.UpdateOrderStatusUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i1007.GetDrivingRouteUseCase>(
      () => _i1007.GetDrivingRouteUseCase(gh<_i724.PickupLocationRepo>()),
    );
    gh.factory<_i841.OrderDetailsCubit>(
      () => _i841.OrderDetailsCubit(
        getDriverOrderDetailsUseCase: gh<_i837.GetDriverOrderDetailsUseCase>(),
        updateOrderStatusUseCase: gh<_i591.UpdateOrderStatusUseCase>(),
        reportDriverLocationUseCase: gh<_i59.ReportDriverLocationUseCase>(),
      ),
    );
    gh.factory<_i719.PickupLocationCubit>(
      () => _i719.PickupLocationCubit(gh<_i1007.GetDrivingRouteUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}

class _$SecureStorageModule extends _i327.SecureStorageModule {}

class _$DioModule extends _i977.DioModule {}
