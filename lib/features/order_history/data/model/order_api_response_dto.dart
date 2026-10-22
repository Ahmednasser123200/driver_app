import 'package:json_annotation/json_annotation.dart';

import 'api_envelope.dart';

part 'order_api_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class OrderApiResponseDto<T> implements ApiEnvelope<T> {
  final bool success;
  @override
  final String message;
  @override
  final T? data;
  final Object? error;

  const OrderApiResponseDto({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  @override
  bool get isOk => success;

  factory OrderApiResponseDto.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$OrderApiResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$OrderApiResponseDtoToJson(this, toJsonT);
}