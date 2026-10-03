import 'package:driver_app/features/auth/domain/entities/login_entity/user_entity.dart';
import 'package:equatable/equatable.dart';

class LoginEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String driverStatus;
  final UserEntity? user;

  const LoginEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.driverStatus,
    this.user,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    expiresIn,
    driverStatus,
    user
  ];
}
