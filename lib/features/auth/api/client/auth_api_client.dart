
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_strings/api_strings.dart';
import '../../data/model/request/login_request/login_request.dart';
import '../../data/model/response/login_response/login_response.dart';

part 'auth_api_client.g.dart';

@singleton
@RestApi()
abstract class AuthApiClient {
@factoryMethod
factory AuthApiClient(Dio dio) = _AuthApiClient;

@POST(ApiStrings.login)
Future<LoginResponse> login(@Body() LoginRequest request);

}