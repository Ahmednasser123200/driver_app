// // lib/dev_login.dart
// // TEMPORARY - DO NOT COMMIT. Delete this file and its call in main.dart.
// import 'package:dio/dio.dart';
// import 'package:driver_app/config/di/di.dart';
// import 'package:driver_app/config/dio/auth_interceptor.dart';
// import 'package:driver_app/core/constants/api_strings/api_strings.dart';
// import 'package:flutter/foundation.dart';
//
// Future<void> devLogin() async {
//   if (!kDebugMode) return;
//   try {
//     final token = await _fetchAccessToken();
//     await getIt<AuthInterceptors>().setToken(token);
//     debugPrint('devLogin: token saved');
//   } catch (e) {
//     debugPrint('devLogin failed: $e');
//   }
// }
//
// Future<String> _fetchAccessToken() async {
//   final dio = Dio(
//     BaseOptions(
//       baseUrl: ApiStrings.baseUrl,
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 5),
//     ),
//   );
//   final response = await dio.post(
//     ApiStrings.login,
//     data: {
//       'email': 'string1@gmail.com',
//       'password': 'Qwert@123',
//       'deviceId': 'device_abc123',
//       'fcmToken': 'fcm_token_xyz',
//     },
//   );
//   return response.data['accessToken'] as String;
// }