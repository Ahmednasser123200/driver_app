import 'package:driver_app/config/errors/app_failure.dart';
import 'package:equatable/equatable.dart';

class BaseState<T> extends Equatable {
  final String errorMessage;
  final AppFailure? failure;
  final bool isLoading;
  final T? data;

  const BaseState({
    this.isLoading = false,
    this.errorMessage = '',
    this.data,
    this.failure,
  });

  static const _clearValue = Object();

  BaseState<T> copyWith({
    String? errorMessage,
    bool clearFailure = false,
    bool? isLoading,
    Object? data = _clearValue,
    Object? failure = _clearValue,
  }) {
    return BaseState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      failure: clearFailure
          ? null
          : identical(failure, _clearValue)
          ? this.failure
          : failure as AppFailure?,
      data: identical(data, _clearValue) ? this.data : data as T?,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, data, failure];
}
