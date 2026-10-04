import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';

import 'login_intent.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginState());

  Future<void> handle(LoginIntent intent) async {
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
        await _login();
    }
  }

  Future<void> _login() async {
    emit(
      state.copyWith(isLoading: true, errorMessage: '', loginSuccess: false),
    );

    final result = await _loginUseCase(
      LoginCredentials(email: state.email.trim(), password: state.password),
      rememberMe: state.rememberMe,
    );
    switch (result) {
      case Success<LoginEntity>(data: final login):
        emit(state.copyWith(isLoading: false, data: login, loginSuccess: true));
        emitEvent(const ShowSuccessMessage(AppStrings.loggedInSuccessfully));

        if (login.driverStatus.toLowerCase() ==
            AppStrings.statusPending.toLowerCase()) {
          emitEvent(const ShowErrorMessage(message: AppStrings.loginFailed));
        } else {
          emitEvent(const NavigateTo(Routes.home));
        }

      case Error<LoginEntity>(:final failure):
        emit(state.copyWith(isLoading: false));
        emitEvent(ShowErrorMessage(failure: failure));
    }
  }
}
