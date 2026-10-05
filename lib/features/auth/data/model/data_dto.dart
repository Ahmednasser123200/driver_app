import 'dart:convert';

import '../../domain/entities/login_entity/login_entity.dart';

import 'package:driver_app/features/auth/data/model/user_dto.dart';

import 'package:json_annotation/json_annotation.dart';

part 'data_dto.g.dart';

@JsonSerializable(createFactory: false)
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

  LoginDataDto({this.accessToken, this.refreshToken, this.expiresIn, this.driverStatus, this.user});
  factory LoginDataDto.fromJson(Map<String, dynamic> json) {
    return LoginDataDto(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      driverStatus: json['driverStatus'] as String?,
      user: json['user'] == null
          ? null
          : UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() => _$LoginDataDtoToJson(this);
  LoginEntity toLoginEntity() => LoginEntity(accessToken: accessToken ?? '', refreshToken: refreshToken ?? '', expiresIn: expiresIn ?? 0, driverStatus: driverStatus ?? '', user: user?.toUserEntity());
}

