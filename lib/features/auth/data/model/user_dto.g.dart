// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: userIdFromJson(json['id']),
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  gender: json['gender'] as String?,
  role: json['role'] as String?,
  photoUrl: json['photoUrl'] as String?,
  status: json['status'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'gender': instance.gender,
  'role': instance.role,
  'photoUrl': instance.photoUrl,
  'status': instance.status,
  'isActive': instance.isActive,
};
