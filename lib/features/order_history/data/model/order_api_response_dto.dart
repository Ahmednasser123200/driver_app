import 'package:json_annotation/json_annotation.dart';

part 'order_api_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class OrderApiResponseDto<T> {
  final bool success;
  final String message;
  final T? data;
  final Object? error;

  const OrderApiResponseDto({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory OrderApiResponseDto.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$OrderApiResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$OrderApiResponseDtoToJson(this, toJsonT);
}