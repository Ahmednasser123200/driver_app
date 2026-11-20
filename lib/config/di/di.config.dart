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
import '../../core/services/url_launcher/url_launcher_service.dart' as _i156;
import '../../core/services/url_launcher/url_launcher_service_impl.dart'
    as _i921;
import '../../core/services/url_launcher/url_launcher_wrapper.dart' as _i920;
import '../../features/delivery_map/api/client/routing_api_client.dart'
    as _i968;
import '../../features/delivery_map/api/routing_api_module.dart' as _i523;
import '../../features/delivery_map/data/datasources/routing_remote_data_source.dart'
    as _i75;
import '../../features/delivery_map/data/datasources/routing_remote_data_source_impl.dart'
    as _i665;
import '../../features/delivery_map/data/repository/routing_repository_impl.dart'
    as _i454;
import '../../features/delivery_map/domain/repository/routing_repository.dart'
    as _i382;
import '../../features/delivery_map/domain/use_case/check_location_permission_use_case.dart'
    as _i209;
import '../../features/delivery_map/domain/use_case/get_current_driver_location_use_case.dart'
    as _i688;
import '../../features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart'
    as _i516;
import '../../features/delivery_map/domain/use_case/get_route_use_case.dart'
    as _i368;
import '../../features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart'
    as _i1002;
import '../../features/home/api/client/home_api_client.dart' as _i773;
import '../../features/home/api/data_source_impl/remote/home_remote_data_source_impl.dart'
    as _i1054;
import '../../features/home/data/datasources/home_remote_data_source.dart'
    as _i362;
import '../../features/home/data/repo/home_repo_impl.dart' as _i1024;
import '../../features/home/domain/repo/home_repo.dart' as _i280;
import '../../features/home/domain/usecases/accept_order_use_case.dart'
    as _i982;
import '../../features/home/domain/usecases/get_available_orders_use_case.dart'
    as _i216;
import '../../features/home/presentation/manager/cubit/home_cubit.dart'
    as _i740;
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
    final routingApiModule = _$RoutingApiModule();
    final dioModule = _$DioModule();
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.lazySingleton<_i970.GeolocatorWrapper>(
      () => const _i970.GeolocatorWrapper(),
    );
    gh.lazySingleton<_i920.UrlLauncherWrapper>(
      () => const _i920.UrlLauncherWrapper(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => routingApiModule.googleRoutesDio(),
      instanceName: 'googleRoutes',
    );
    gh.lazySingleton<_i839.AuthInterceptors>(
      () => _i839.AuthInterceptors(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i839.AuthInterceptors>()),
    );
    gh.singleton<_i773.HomeApiClient>(
      () => _i773.HomeApiClient(gh<_i361.Dio>()),
    );
    gh.singleton<_i329.OrderDetailsApiClient>(
      () => _i329.OrderDetailsApiClient(gh<_i361.Dio>()),
    );
    gh.singleton<_i968.RoutingApiClient>(
      () => _i968.RoutingApiClient(gh<_i361.Dio>(instanceName: 'googleRoutes')),
    );
    gh.factory<_i702.OrderDetailsRemoteDataSource>(
      () => _i537.OrderDetailsRemoteDataSourceImpl(
        gh<_i329.OrderDetailsApiClient>(),
      ),
    );
    gh.lazySingleton<_i156.UrlLauncherService>(
      () => _i921.UrlLauncherServiceImpl(gh<_i920.UrlLauncherWrapper>()),
    );
    gh.lazySingleton<_i898.LocationService>(
      () => _i614.LocationServiceImpl(gh<_i970.GeolocatorWrapper>()),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i362.HomeRemoteDataSource>(
      () => _i1054.HomeRemoteDataSourceImpl(gh<_i773.HomeApiClient>()),
    );
    gh.lazySingleton<_i75.RoutingRemoteDataSource>(
      () => _i665.RoutingRemoteDataSourceImpl(gh<_i968.RoutingApiClient>()),
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
    gh.factory<_i280.HomeRepo>(
      () => _i1024.HomeRepoImpl(gh<_i362.HomeRemoteDataSource>()),
    );
    gh.factory<_i837.GetDriverOrderDetailsUseCase>(
      () => _i837.GetDriverOrderDetailsUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i591.UpdateOrderStatusUseCase>(
      () => _i591.UpdateOrderStatusUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i982.AcceptOrderUseCase>(
      () => _i982.AcceptOrderUseCase(gh<_i280.HomeRepo>()),
    );
    gh.factory<_i216.GetAvailableOrdersUseCase>(
      () => _i216.GetAvailableOrdersUseCase(gh<_i280.HomeRepo>()),
    );
    gh.factory<_i740.HomeCubit>(
      () => _i740.HomeCubit(
        acceptOrderUseCase: gh<_i982.AcceptOrderUseCase>(),
        getAvailableOrdersUseCase: gh<_i216.GetAvailableOrdersUseCase>(),
      ),
    );
    gh.lazySingleton<_i382.RoutingRepository>(
      () => _i454.RoutingRepositoryImpl(gh<_i75.RoutingRemoteDataSource>()),
    );
    gh.factory<_i209.CheckLocationPermissionUseCase>(
      () => _i209.CheckLocationPermissionUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i688.GetCurrentDriverLocationUseCase>(
      () => _i688.GetCurrentDriverLocationUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i516.GetDriverLocationStreamUseCase>(
      () => _i516.GetDriverLocationStreamUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i841.OrderDetailsCubit>(
      () => _i841.OrderDetailsCubit(
        getDriverOrderDetailsUseCase: gh<_i837.GetDriverOrderDetailsUseCase>(),
        updateOrderStatusUseCase: gh<_i591.UpdateOrderStatusUseCase>(),
        reportDriverLocationUseCase: gh<_i59.ReportDriverLocationUseCase>(),
      ),
    );
    gh.factory<_i368.GetRouteUseCase>(
      () => _i368.GetRouteUseCase(gh<_i382.RoutingRepository>()),
    );
    gh.factory<_i1002.DeliveryMapCubit>(
      () => _i1002.DeliveryMapCubit(
        getDriverLocationStreamUseCase:
            gh<_i516.GetDriverLocationStreamUseCase>(),
        checkLocationPermissionUseCase:
            gh<_i209.CheckLocationPermissionUseCase>(),
        getCurrentDriverLocationUseCase:
            gh<_i688.GetCurrentDriverLocationUseCase>(),
        getRouteUseCase: gh<_i368.GetRouteUseCase>(),
        urlLauncherService: gh<_i156.UrlLauncherService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}

class _$SecureStorageModule extends _i327.SecureStorageModule {}

class _$RoutingApiModule extends _i523.RoutingApiModule {}

class _$DioModule extends _i977.DioModule {}
