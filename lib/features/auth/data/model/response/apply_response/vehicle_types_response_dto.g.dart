// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_types_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleTypesResponseDto _$VehicleTypesResponseDtoFromJson(
  Map<String, dynamic> json,
) => VehicleTypesResponseDto(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => VehicleTypeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VehicleTypesResponseDtoToJson(
  VehicleTypesResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
