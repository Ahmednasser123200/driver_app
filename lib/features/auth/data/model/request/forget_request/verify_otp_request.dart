// To parse this JSON data, do
//
//     final verifyotprequest = verifyotprequestFromJson(jsonString);

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'verify_otp_request.g.dart';

VerifyOtpRequest verifyOtpRequestFromJson(String str) =>
    VerifyOtpRequest.fromJson(json.decode(str));

String verifyOtpRequestToJson(VerifyOtpRequest data) =>
    json.encode(data.toJson());

@JsonSerializable()
class VerifyOtpRequest extends Equatable {
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "otp")
  final String otp;

  const VerifyOtpRequest({required this.email, required this.otp});

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);

  @override
  List<Object?> get props => [email, otp];
}
