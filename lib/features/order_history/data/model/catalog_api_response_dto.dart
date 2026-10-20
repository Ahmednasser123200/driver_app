import 'package:json_annotation/json_annotation.dart';

import 'api_envelope.dart';

part 'catalog_api_response_dto.g.dart';

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
