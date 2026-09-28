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

import '../../features/auth/api/client/auth_client.dart' as _i824;
import '../../features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart'
    as _i319;
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart'
    as _i885;
import '../../features/auth/data/repo_impl/auth_repo_impl.dart' as _i279;
import '../../features/auth/domain/repo/auth_repo.dart' as _i170;
import '../../features/auth/domain/use_case/add_application_use_case.dart'
    as _i823;
import '../../features/auth/presentation/apply/manager/apply_cubit.dart'
    as _i1009;
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
    gh.singleton<_i824.AuthClient>(() => _i824.AuthClient(gh<_i361.Dio>()));
    gh.factory<_i885.AuthRemoteDataSource>(
      () => _i319.AuthRemoteDataSourceImpl(gh<_i824.AuthClient>()),
    );
    gh.factory<_i170.AuthRepo>(
      () => _i279.AuthRepoImpl(gh<_i885.AuthRemoteDataSource>()),
    );
    gh.factory<_i823.AddApplicationUseCase>(
      () => _i823.AddApplicationUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i1009.ApplyCubit>(
      () => _i1009.ApplyCubit(gh<_i823.AddApplicationUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}

class _$SecureStorageModule extends _i327.SecureStorageModule {}

class _$DioModule extends _i977.DioModule {}
