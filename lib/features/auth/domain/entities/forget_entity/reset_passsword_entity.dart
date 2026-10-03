import 'package:equatable/equatable.dart';

class ResetPasswordEntity extends Equatable {
  final bool isSuccess;
  final String message;
  const ResetPasswordEntity({required this.isSuccess, required this.message});

  @override
  List<Object?> get props => [
    isSuccess,
    message
  ];
}
