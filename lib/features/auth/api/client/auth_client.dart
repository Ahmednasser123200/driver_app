import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/model/response/apply_response/application_response_dto.dart';

part 'auth_client.g.dart';

@singleton
@RestApi()
abstract class AuthClient {
  @factoryMethod
  factory AuthClient(Dio dio) = _AuthClient;

  @POST('/api/v1/drivers/applications')
  @MultiPart()
  Future<ApplicationResponseDto> addApplication(
      @Part(name: 'countryCode') String countryCode,
      @Part(name: 'firstName') String firstName,
      @Part(name: 'secondName') String secondName,
      @Part(name: 'vehicleType') String vehicleType,
      @Part(name: 'vehicleNumber') String vehicleNumber,
      @Part(name: 'email') String email,
      @Part(name: 'phoneNumber') String phoneNumber,
      @Part(name: 'nationalId') String nationalId,
      @Part(name: 'password') String password,
      @Part(name: 'confirmPassword') String confirmPassword,
      @Part(name: 'gender') String gender,
      @Part(name: 'vehicleLicenceFile') File? vehicleLicenceFile,
      @Part(name: 'idImage') File? idImage,
      );
}