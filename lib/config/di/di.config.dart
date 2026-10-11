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
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/services/media_service.dart' as _i902;
import '../../core/services/media_service_impl.dart' as _i679;
import '../../core/services/token_storage_service.dart' as _i724;
import '../../features/auth/api/client/auth_api_client.dart' as _i213;
import '../../features/auth/api/client/auth_client.dart' as _i824;
import '../../features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart'
    as _i319;
import '../../features/auth/api/service/secure_storage.dart' as _i688;
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart'
    as _i885;
import '../../features/auth/data/repo_impl/auth_repo_impl.dart' as _i279;
import '../../features/auth/domain/repo/auth_repo.dart' as _i170;
import '../../features/auth/domain/use_case/add_application_use_case.dart'
    as _i823;
import '../../features/auth/domain/use_case/forget_password_use_case.dart'
    as _i90;
import '../../features/auth/domain/use_case/get_countries_use_case.dart'
    as _i374;
import '../../features/auth/domain/use_case/get_vehicle_types_use_case.dart'
    as _i911;
import '../../features/auth/domain/use_case/login_use_case.dart' as _i973;
import '../../features/auth/domain/use_case/reset_password_use_case.dart'
    as _i149;
import '../../features/auth/domain/use_case/verify_otp_use_case.dart' as _i69;
import '../../features/auth/presentation/apply/manager/apply_cubit.dart'
    as _i1009;
import '../../features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart'
    as _i667;
import '../../features/auth/presentation/login/manager/login_cubit.dart'
    as _i889;
import '../dio/auth_interceptor.dart' as _i839;
import '../dio/dio_module.dart' as _i977;
import '../localization/locale_provider.dart' as _i303;
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
    gh.lazySingleton<_i183.ImagePicker>(() => appModule.imagePicker);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.factory<_i303.LocaleProvider>(() => _i303.LocaleProviderImpl());
    gh.lazySingleton<_i688.SecureStorageService>(
      () => _i688.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i724.TokenStorageService>(
      () => _i724.TokenStorageServiceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i839.AuthInterceptors>(
      () => _i839.AuthInterceptors(gh<_i724.TokenStorageService>()),
    );
    gh.lazySingleton<_i902.MediaService>(
      () => _i679.MediaServiceImpl(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i839.AuthInterceptors>()),
    );
    gh.singleton<_i213.AuthApiClient>(
      () => _i213.AuthApiClient(gh<_i361.Dio>()),
    );
    gh.singleton<_i824.AuthClient>(() => _i824.AuthClient(gh<_i361.Dio>()));
    gh.factory<_i885.AuthRemoteDataSource>(
      () => _i319.AuthRemoteDataSourceImpl(
        gh<_i824.AuthClient>(),
        gh<_i213.AuthApiClient>(),
      ),
    );
    gh.factory<_i170.AuthRepo>(
      () => _i279.AuthRepoImpl(
        gh<_i885.AuthRemoteDataSource>(),
        gh<_i724.TokenStorageService>(),
        gh<_i688.SecureStorageService>(),
      ),
    );
    gh.factory<_i90.ForgetPasswordUserCase>(
      () => _i90.ForgetPasswordUserCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i149.ResetPasswordUserCase>(
      () => _i149.ResetPasswordUserCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i69.VerifyOtpUseCase>(
      () => _i69.VerifyOtpUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i823.AddApplicationUseCase>(
      () => _i823.AddApplicationUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i374.GetCountriesUseCase>(
      () => _i374.GetCountriesUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i911.GetVehicleTypesUseCase>(
      () => _i911.GetVehicleTypesUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i973.LoginUseCase>(
      () => _i973.LoginUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i889.LoginCubit>(
      () => _i889.LoginCubit(gh<_i973.LoginUseCase>()),
    );
    gh.factory<_i667.ForgetPasswordCubit>(
      () => _i667.ForgetPasswordCubit(
        gh<_i90.ForgetPasswordUserCase>(),
        gh<_i69.VerifyOtpUseCase>(),
        gh<_i149.ResetPasswordUserCase>(),
      ),
    );
    gh.factory<_i1009.ApplyCubit>(
      () => _i1009.ApplyCubit(
        gh<_i823.AddApplicationUseCase>(),
        gh<_i374.GetCountriesUseCase>(),
        gh<_i911.GetVehicleTypesUseCase>(),
        gh<_i902.MediaService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}

class _$SecureStorageModule extends _i327.SecureStorageModule {}

class _$DioModule extends _i977.DioModule {}
