// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelopes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderApiResponseDto<T> _$OrderApiResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => OrderApiResponseDto<T>(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  error: json['error'],
);

Map<String, dynamic> _$OrderApiResponseDtoToJson<T>(
  OrderApiResponseDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'error': instance.error,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

CatalogApiResponseDto<T> _$CatalogApiResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => CatalogApiResponseDto<T>(
  isSuccess: json['isSuccess'] as bool,
  message: json['message'] as String,
  messageLocalized: json['messageLocalized'] as String?,
  statusCode: json['statusCode'] as String,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$CatalogApiResponseDtoToJson<T>(
  CatalogApiResponseDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'message': instance.message,
  'messageLocalized': instance.messageLocalized,
  'statusCode': instance.statusCode,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};
