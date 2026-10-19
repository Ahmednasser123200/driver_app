import 'package:json_annotation/json_annotation.dart';

part 'catalog_api_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class CatalogApiResponseDto<T> {
  final bool isSuccess;
  final String message;
  final String? messageLocalized;
  final String statusCode;
  final T? data;

  const CatalogApiResponseDto({
    required this.isSuccess,
    required this.message,
    this.messageLocalized,
    required this.statusCode,
    this.data,
  });

  factory CatalogApiResponseDto.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$CatalogApiResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$CatalogApiResponseDtoToJson(this, toJsonT);
}