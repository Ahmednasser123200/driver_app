import 'package:driver_app/config/errors/app_failure.dart';
import 'package:equatable/equatable.dart';

class BaseState<T> extends Equatable {
  final AppFailure? errorMessage;
  final bool isLoading;
  final T? data;

  const BaseState({this.isLoading = false, this.errorMessage, this.data});

  static const _clearValue = Object();

  BaseState<T> copyWith({
    Object? errorMessage = _clearValue,
    bool? isLoading,
    Object? data = _clearValue,
  }) {
    return BaseState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _clearValue)
          ? this.errorMessage
          : errorMessage as AppFailure?,
      data: identical(data, _clearValue) ? this.data : data as T?,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, data];
}
