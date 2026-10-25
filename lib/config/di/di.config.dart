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
    final dioModule = _$DioModule();
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
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
    gh.factory<_i702.OrderDetailsRemoteDataSource>(
      () => _i537.OrderDetailsRemoteDataSourceImpl(
        gh<_i329.OrderDetailsApiClient>(),
      ),
    );
    gh.factory<_i788.OrderDetailsRepo>(
      () =>
          _i692.OrderDetailsRepoImpl(gh<_i702.OrderDetailsRemoteDataSource>()),
    );
    gh.factory<_i362.HomeRemoteDataSource>(
      () => _i1054.HomeRemoteDataSourceImpl(gh<_i773.HomeApiClient>()),
    );
    gh.factory<_i280.HomeRepo>(
      () => _i1024.HomeRepoImpl(gh<_i362.HomeRemoteDataSource>()),
    );
    gh.factory<_i837.GetDriverOrderDetailsUseCase>(
      () => _i837.GetDriverOrderDetailsUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i59.ReportDriverLocationUseCase>(
      () => _i59.ReportDriverLocationUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i591.UpdateOrderStatusUseCase>(
      () => _i591.UpdateOrderStatusUseCase(gh<_i788.OrderDetailsRepo>()),
    );
    gh.factory<_i841.OrderDetailsCubit>(
      () => _i841.OrderDetailsCubit(
        getDriverOrderDetailsUseCase: gh<_i837.GetDriverOrderDetailsUseCase>(),
        updateOrderStatusUseCase: gh<_i591.UpdateOrderStatusUseCase>(),
      ),
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
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}

class _$SecureStorageModule extends _i327.SecureStorageModule {}

class _$DioModule extends _i977.DioModule {}
