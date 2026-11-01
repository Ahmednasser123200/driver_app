// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOtpDataDto _$VerifyOtpDataDtoFromJson(Map<String, dynamic> json) =>
    VerifyOtpDataDto(
      resetToken: _readResetToken(json, 'resetToken') as String?,
      expiresAtUtc: _readExpiresAtUtc(json, 'expiresAtUtc') == null
          ? null
          : DateTime.parse(_readExpiresAtUtc(json, 'expiresAtUtc') as String),
    );

Map<String, dynamic> _$VerifyOtpDataDtoToJson(VerifyOtpDataDto instance) =>
    <String, dynamic>{
      'resetToken': instance.resetToken,
      'expiresAtUtc': instance.expiresAtUtc?.toIso8601String(),
    };

LoginDataDto _$LoginDataDtoFromJson(Map<String, dynamic> json) => LoginDataDto(
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  expiresIn: (json['expiresIn'] as num?)?.toInt(),
  driverStatus: json['driverStatus'] as String?,
  user: json['user'] == null
      ? null
      : UserDto.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginDataDtoToJson(LoginDataDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'driverStatus': instance.driverStatus,
      'user': instance.user,
    };
