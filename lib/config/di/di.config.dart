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
import '../../features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart'
    as _i319;
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart'
    as _i885;
import '../../features/auth/data/repo_impl/auth_repo_impl.dart' as _i279;
import '../../features/auth/domain/repo/auth_repo.dart' as _i170;
import '../../features/auth/domain/use_case/add_application_use_case.dart'
    as _i823;
import '../../features/auth/domain/use_case/delete_remembered_email_use_case.dart'
    as _i25;
import '../../features/auth/domain/use_case/forget_password_use_case.dart'
    as _i90;
import '../../features/auth/domain/use_case/get_countries_use_case.dart'
    as _i374;
import '../../features/auth/domain/use_case/get_remembered_email_use_case.dart'
    as _i1044;
import '../../features/auth/domain/use_case/get_vehicle_types_use_case.dart'
    as _i911;
import '../../features/auth/domain/use_case/login_use_case.dart' as _i973;
import '../../features/auth/domain/use_case/reset_password_use_case.dart'
    as _i149;
import '../../features/auth/domain/use_case/save_remembered_email_use_case.dart'
    as _i705;
import '../../features/auth/domain/use_case/verify_otp_use_case.dart' as _i69;
import '../../features/auth/presentation/apply/manager/apply_cubit.dart'
    as _i1009;
import '../../features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart'
    as _i667;
import '../../features/auth/presentation/login/manager/login_cubit.dart'
    as _i889;
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
import '../../features/order_history/api/client/order_history_api_client.dart'
    as _i380;
import '../../features/order_history/api/data_source_impl/order_history_remote_data_source_impl.dart'
    as _i1042;
import '../../features/order_history/data/data_source/order_history_remote_data_source.dart'
    as _i794;
import '../../features/order_history/data/repo_impl/order_history_repo_impl.dart'
    as _i325;
import '../../features/order_history/domain/repo/order_history_repo.dart'
    as _i184;
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
    gh.singleton<_i329.OrderDetailsApiClient>(
      () => _i329.OrderDetailsApiClient(gh<_i361.Dio>()),
    );
    gh.singleton<_i380.OrderHistoryApiClient>(
      () => _i380.OrderHistoryApiClient(gh<_i361.Dio>()),
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
    gh.factory<_i885.AuthRemoteDataSource>(
      () => _i319.AuthRemoteDataSourceImpl(gh<_i213.AuthApiClient>()),
    );
    gh.factory<_i794.OrderHistoryRemoteDataSource>(
      () => _i1042.OrderHistoryRemoteDataSourceImpl(
        gh<_i380.OrderHistoryApiClient>(),
      ),
    );
    gh.factory<_i184.OrderHistoryRepo>(
      () =>
          _i325.OrderHistoryRepoImpl(gh<_i794.OrderHistoryRemoteDataSource>()),
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
    gh.factory<_i170.AuthRepo>(
      () => _i279.AuthRepoImpl(
        gh<_i885.AuthRemoteDataSource>(),
        gh<_i724.TokenStorageService>(),
      ),
    );
    gh.factory<_i566.GetOrderHistoryDetailsUseCase>(
      () => _i566.GetOrderHistoryDetailsUseCase(gh<_i184.OrderHistoryRepo>()),
    );
    gh.factory<_i781.GetOrdersUseCase>(
      () => _i781.GetOrdersUseCase(gh<_i184.OrderHistoryRepo>()),
    );
    gh.factory<_i649.WatchOrderUpdatesUseCase>(
      () => _i649.WatchOrderUpdatesUseCase(gh<_i184.OrderHistoryRepo>()),
    );
    gh.factory<_i476.OrderHistoryDetailsCubit>(
      () => _i476.OrderHistoryDetailsCubit(
        gh<_i566.GetOrderHistoryDetailsUseCase>(),
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
    gh.factory<_i25.DeleteRememberedEmailUseCase>(
      () => _i25.DeleteRememberedEmailUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i374.GetCountriesUseCase>(
      () => _i374.GetCountriesUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i1044.GetRememberedEmailUseCase>(
      () => _i1044.GetRememberedEmailUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i911.GetVehicleTypesUseCase>(
      () => _i911.GetVehicleTypesUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i973.LoginUseCase>(
      () => _i973.LoginUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i705.SaveRememberedEmailUseCase>(
      () => _i705.SaveRememberedEmailUseCase(gh<_i170.AuthRepo>()),
    );
    gh.factory<_i134.OrdersCubit>(
      () => _i134.OrdersCubit(gh<_i781.GetOrdersUseCase>()),
    );
    gh.factory<_i889.LoginCubit>(
      () => _i889.LoginCubit(
        gh<_i973.LoginUseCase>(),
        gh<_i1044.GetRememberedEmailUseCase>(),
      ),
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
    gh.singleton<_i773.HomeApiClient>(
      () => _i773.HomeApiClient(gh<_i361.Dio>()),
    );
    gh.factory<_i362.HomeRemoteDataSource>(
      () => _i1054.HomeRemoteDataSourceImpl(gh<_i773.HomeApiClient>()),
    );
    gh.factory<_i280.HomeRepo>(
      () => _i1024.HomeRepoImpl(gh<_i362.HomeRemoteDataSource>()),
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
