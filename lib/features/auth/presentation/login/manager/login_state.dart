import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';

class LoginState extends BaseState<LoginEntity> {
  final String email;
  final String password;
  final bool rememberMe;
  final bool obscurePassword;

  const LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.obscurePassword = true,
    super.isLoading,
    super.errorMessage,
    super.data,
  });

  @override
  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? obscurePassword,
    bool? isLoading,
    String? errorMessage,
    Object? data = const Object(),
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: identical(data, const Object()) ? this.data : data as LoginEntity?,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    email,
    password,
    rememberMe,
    obscurePassword,
  ];
}