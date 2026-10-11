import 'package:equatable/equatable.dart';

class VerifyOtpEntity extends Equatable {
  final String resetToken;
  final DateTime expiresAtUtc;

  const VerifyOtpEntity({required this.resetToken, required this.expiresAtUtc});

  @override
  List<Object?> get props => [resetToken, expiresAtUtc];
}
