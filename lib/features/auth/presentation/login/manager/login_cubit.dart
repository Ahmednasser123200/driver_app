import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/app_strings/app_strings.dart';
import '../../../domain/use_case/delete_remembered_email_use_case.dart';
import '../../../domain/use_case/load_remembered_email_use_case.dart';
import '../../../domain/use_case/save_remembered_email_use_case.dart';
import 'login_intent.dart';
import 'login_state.dart';
import 'login_ui_event.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final LoginUseCase _loginUseCase;

  final LoadRememberedEmailUseCase _loadRememberedEmailUseCase;
  final SaveRememberedEmailUseCase _saveRememberedEmailUseCase;
  final DeleteRememberedEmailUseCase _deleteRememberedEmailUseCase;

  LoginCubit(
    this._loginUseCase,
    this._saveRememberedEmailUseCase,
    this._deleteRememberedEmailUseCase,
    this._loadRememberedEmailUseCase,
  ) : super(const LoginState());

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
        _login();
      case LoadRememberedEmail():
        _loadRememberedEmail();
    }
  }

  Future<void> _loadRememberedEmail() async {
    final savedEmail = await _loadRememberedEmailUseCase();
    if (savedEmail != null && savedEmail.isNotEmpty && state.email.isEmpty) {
      emit(state.copyWith(email: savedEmail, rememberMe: true));
      emitEvent(EmailPreFilledEvent(savedEmail));
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
        if (state.rememberMe) {
          await _saveRememberedEmailUseCase(state.email);
        } else {
          await _deleteRememberedEmailUseCase();
        }

        emit(state.copyWith(isLoading: false, data: login, loginSuccess: true));
        emitEvent(const ShowSuccessMessage(AppStrings.loggedInSuccessfully));

        if (login.driverStatus.toLowerCase() == AppStrings.statusPending) {
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
