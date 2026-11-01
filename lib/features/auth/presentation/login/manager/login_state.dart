import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';

import '../../../../../config/errors/app_failure.dart';

class LoginState extends BaseState<LoginEntity> {
  final String email;
  final String password;
  final bool rememberMe;
  final bool loginSuccess;
  final bool obscurePassword;

  const LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.obscurePassword = true,
    this.loginSuccess = false,
    super.isLoading,
    super.errorMessage,
    super.data,
    super.failure, // <---added: مينفعش نسيه
  });

  bool get isFormFilled => email.trim().isNotEmpty && password.isNotEmpty;

  static const _keep = Object();   // <--Added: بدل const Object() جوّه السيجنيتشر

  @override
  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? loginSuccess,
    bool? obscurePassword,
    bool? isLoading,
    String? errorMessage,
    Object? data = _keep,
    Object? failure = _keep,       // <--Added: دي اللي كانت ناقصة
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: identical(data, _keep) ? this.data : data as LoginEntity?,
      failure: identical(failure, _keep) ? this.failure : failure as AppFailure?,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    email,
    password,
    rememberMe,
    loginSuccess,
    obscurePassword,
  ];
}