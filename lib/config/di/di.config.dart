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

import '../../features/order_history/api/client/order_history_api_client.dart'
    as _i380;
import '../../features/order_history/api/data_source_impl/order_history_remote_data_source_impl.dart'
    as _i1042;
import '../../features/order_history/data/data_source/order_history_remote_data_source.dart'
    as _i794;
import '../../features/order_history/data/repo_impl/order_history_repo_impl.dart'
    as _i325;
import '../../features/order_history/domain/repo/order_history_repo.dart'
    as _i183;
import '../../features/order_history/domain/use_case/get_order_history_details_use_case.dart'
    as _i566;
import '../../features/order_history/domain/use_case/get_orders_use_case.dart'
    as _i781;
import '../../features/order_history/domain/use_case/watch_order_updates_use_case.dart'
    as _i649;
import '../../features/order_history/presentation/manager/order_history_details_cubit.dart'
    as _i476;
import '../../features/order_history/presentation/manager/orders_cubit.dart'
    as _i134;
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
    gh.singleton<_i380.OrderHistoryApiClient>(
      () => _i380.OrderHistoryApiClient(gh<_i361.Dio>()),
    );
    gh.factory<_i794.OrderHistoryRemoteDataSource>(
      () => _i1042.OrderHistoryRemoteDataSourceImpl(
        gh<_i380.OrderHistoryApiClient>(),
      ),
    );
    gh.factory<_i183.OrderHistoryRepo>(
      () =>
          _i325.OrderHistoryRepoImpl(gh<_i794.OrderHistoryRemoteDataSource>()),
    );
    gh.factory<_i566.GetOrderHistoryDetailsUseCase>(
      () => _i566.GetOrderHistoryDetailsUseCase(gh<_i183.OrderHistoryRepo>()),
    );
    gh.factory<_i781.GetOrdersUseCase>(
      () => _i781.GetOrdersUseCase(gh<_i183.OrderHistoryRepo>()),
    );
    gh.factory<_i649.WatchOrderUpdatesUseCase>(
      () => _i649.WatchOrderUpdatesUseCase(gh<_i183.OrderHistoryRepo>()),
    );
    gh.factory<_i476.OrderHistoryDetailsCubit>(
      () => _i476.OrderHistoryDetailsCubit(
        gh<_i566.GetOrderHistoryDetailsUseCase>(),
      ),
    );
    gh.factory<_i134.OrdersCubit>(
      () => _i134.OrdersCubit(gh<_i781.GetOrdersUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}

class _$SecureStorageModule extends _i327.SecureStorageModule {}

class _$DioModule extends _i977.DioModule {}
