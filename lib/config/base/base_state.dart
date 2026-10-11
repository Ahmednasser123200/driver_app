import 'package:driver_app/config/errors/app_failure.dart';
import 'package:equatable/equatable.dart';

class BaseState<T> extends Equatable {
  final String errorMessage;
  final bool isLoading;
  final T? data;
  final AppFailure? failure;

  const BaseState({
    this.isLoading = false,
    this.errorMessage = '',
    this.data,
    this.failure,
  });

  static const _clearValue = Object();

  BaseState<T> copyWith({
    String? errorMessage,
    bool? isLoading,
    Object? data = _clearValue,
    Object? failure = _clearValue,
  }) {
    return BaseState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: identical(data, _clearValue) ? this.data : data as T?,
      failure: identical(failure, _clearValue)
          ? this.failure
          : failure as AppFailure?,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, data, failure];
}
