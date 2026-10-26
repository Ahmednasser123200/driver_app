import 'package:json_annotation/json_annotation.dart';

part 'api_envelopes.g.dart';

abstract interface class ApiEnvelope<T> {
  bool get isOk;
  String get message;
  T? get data;
}

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

@JsonSerializable(genericArgumentFactories: true)
class CatalogApiResponseDto<T> implements ApiEnvelope<T> {
  final bool isSuccess;
  @override
  final String message;
  final String? messageLocalized;
  final String statusCode;
  @override
  final T? data;

  const CatalogApiResponseDto({
    required this.isSuccess,
    required this.message,
    this.messageLocalized,
    required this.statusCode,
    this.data,
  });

  @override
  bool get isOk => isSuccess;

  factory CatalogApiResponseDto.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$CatalogApiResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$CatalogApiResponseDtoToJson(this, toJsonT);
}
