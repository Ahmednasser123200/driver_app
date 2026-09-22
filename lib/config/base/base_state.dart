import 'package:equatable/equatable.dart';

class BaseState<T> extends Equatable {
  final String errorMessage;
  final bool isLoading;
  final T? data;

  const BaseState({
    this.isLoading = false,
    this.errorMessage = '',
    this.data,
  });

  static const _clearValue = Object();

  BaseState<T> copyWith({
    String? errorMessage,
    bool? isLoading,
    Object? data = _clearValue,
  }) {
    return BaseState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: identical(data, _clearValue) ? this.data : data as T?,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, data];
}