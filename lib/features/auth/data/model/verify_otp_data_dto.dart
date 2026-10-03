import 'dart:convert';

import 'package:driver_app/features/auth/data/model/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/forget_entity/verify_oto_entity.dart';
import '../../domain/entities/login_entity/login_entity.dart';

part 'verify_otp_data_dto.g.dart';

VerifyOtpDataDto dataDTOFromJson(String str) => VerifyOtpDataDto.fromJson(json.decode(str));
String dataDTOToJson(VerifyOtpDataDto data) => json.encode(data.toJson());

Object? _readResetToken(Map json, String key) => json['resetToken'] ?? json['token'];
Object? _readExpiresAtUtc(Map json, String key) => json['expiresAtUtc'] ?? json['expirationDate'];

@JsonSerializable()
class VerifyOtpDataDto {
  @JsonKey(name: 'resetToken', readValue: _readResetToken)
  String? resetToken;
  @JsonKey(name: 'expiresAtUtc', readValue: _readExpiresAtUtc)
  DateTime? expiresAtUtc;

  VerifyOtpDataDto({this.resetToken, this.expiresAtUtc});

  factory VerifyOtpDataDto.fromJson(Map<String, dynamic> json) => _$VerifyOtpDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpDataDtoToJson(this);

  VerifyOtpEntity toEntity() => VerifyOtpEntity(
    resetToken: resetToken ?? '',
    expiresAtUtc: expiresAtUtc ?? DateTime.now(),
  );
}

@JsonSerializable()
class LoginDataDto {
  @JsonKey(name: 'accessToken')
  String? accessToken;
  @JsonKey(name: 'refreshToken')
  String? refreshToken;
  @JsonKey(name: 'expiresIn')
  int? expiresIn;
  @JsonKey(name: 'driverStatus')
  String? driverStatus;
  @JsonKey(name: 'user')
  UserDto? user;

  LoginDataDto({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.driverStatus,
    this.user,
  });

  factory LoginDataDto.fromJson(Map<String, dynamic> json) => _$LoginDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataDtoToJson(this);

  LoginEntity toLoginEntity() => LoginEntity(
    accessToken: accessToken ?? '',
    refreshToken: refreshToken ?? '',
    expiresIn: expiresIn ?? 0,
    driverStatus: driverStatus ?? '',
    user: user?.toUserEntity(),
  );
}
