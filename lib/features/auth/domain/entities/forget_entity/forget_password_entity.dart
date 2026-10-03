import 'package:equatable/equatable.dart';

class ForgetPasswordEntity extends Equatable {
  final bool isSuccess;
  final String message;
  const ForgetPasswordEntity({required this.isSuccess, required this.message});

  @override
  List<Object?> get props => [
    isSuccess,
    message
  ];
}
