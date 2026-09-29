import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/api/service/secure_storage.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/errors/app_failure.dart';
import 'login_intent.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final LoginUseCase _loginUseCase;
  final SecureStorageService _secureStorage;

  LoginCubit(
      this._loginUseCase,
      this._secureStorage,
      ) : super(const LoginState());

  void handle(LoginIntent intent) {
    switch (intent) {
      case EmailChanged(:final email):
        emit(state.copyWith(email: email, errorMessage: ''));
      case PasswordChanged(:final password):
        emit(state.copyWith(password: password, errorMessage: ''));
      case RememberMeChanged(:final value):
        emit(state.copyWith(rememberMe: value));
      case TogglePasswordVisibility():
        emit(state.copyWith(obscurePassword: !state.obscurePassword));
      case LoginSubmitted():
        _login();
      case LoadSavedEmail():
        _loadSavedEmail();
    }
  }

  Future<void> _loadSavedEmail() async {
    final email = await _secureStorage.getRememberedEmail();
    if (email != null && email.isNotEmpty) {
      emit(state.copyWith(email: email, rememberMe: true));
    }
  }

  Future<void> _login() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final result = await _loginUseCase(
      LoginCredentials(
        email: state.email.trim(),
        password: state.password,
      ),
      rememberMe: state.rememberMe,
    );

    switch (result) {
      case Success(:final data):
        emit(state.copyWith(isLoading: false, data: data));
        emitEvent(const ShowSuccessMessage('تم تسجيل الدخول بنجاح'));

        // التحقق من حالة السائق لتوجيهه للشاشة المناسبة
        if (data.driverStatus.toLowerCase() == 'pending') {
          emitEvent(const NavigateTo(Routes.successApply));
        } else {
          emitEvent(const NavigateTo(Routes.home));
        }

      case Error(:final failure):
      // failure هنا بيحتوي إما على serverMessage أو بيترجم عبر الـ AppFailure
        final String errorMsg = switch (failure) {
          BadRequestFailure(:final serverMessage) => serverMessage ?? 'بيانات الدخول غير صحيحة.',
          ConflictFailure(:final serverMessage) => serverMessage ?? 'حدث تعارض في البيانات.',
          UnprocessableEntityFailure(:final serverMessage) => serverMessage ?? 'بيانات غير مقبولة.',
          InternetConnectionFailure() => 'تأكد من اتصالك بالإنترنت.',
          TimeoutFailure() => 'انتهت مهلة الاتصال بالخادم.',
          _ => 'فشل تسجيل الدخول، تأكد من بياناتك.',
        };
        emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
        emitEvent(ShowErrorMessage(errorMsg));
    }
  }
}