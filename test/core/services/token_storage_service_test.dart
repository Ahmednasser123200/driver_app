void main() {}
// import 'package:driver_app/core/constants/storage_keys.dart';
// import 'package:driver_app/core/services/token_storage_service.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
//
// void main() {
//   late MockFlutterSecureStorage mockStorage;
//   late TokenStorageServiceImpl service;
//
//   setUp(() {
//     mockStorage = MockFlutterSecureStorage();
//     service = TokenStorageServiceImpl(mockStorage);
//   });
//
//   group('TokenStorageServiceImpl - Access Token', () {
//     test(
//       'saveAccessToken with persist: true writes to storage and updates memory cache',
//       () async {
//         when(
//           () => mockStorage.write(
//             key: any(named: 'key'),
//             value: any(named: 'value'),
//           ),
//         ).thenAnswer((_) async {});
//
//         await service.saveAccessToken('token_123', persist: true);
//
//         verify(
//           () => mockStorage.write(
//             key: StorageKeys.kUserToken,
//             value: 'token_123',
//           ),
//         ).called(1);
//         // Verify in-memory cache was updated by calling getAccessToken (should not read storage)
//         final cachedToken = await service.getAccessToken();
//         expect(cachedToken, 'token_123');
//         verifyNever(() => mockStorage.read(key: StorageKeys.kUserToken));
//       },
//     );
//
//     test(
//       'saveAccessToken with persist: false deletes key from storage and updates memory cache',
//       () async {
//         when(
//           () => mockStorage.delete(key: any(named: 'key')),
//         ).thenAnswer((_) async {});
//
//         await service.saveAccessToken('session_token', persist: false);
//
//         verify(() => mockStorage.delete(key: StorageKeys.kUserToken)).called(1);
//         final cachedToken = await service.getAccessToken();
//         expect(cachedToken, 'session_token');
//         verifyNever(() => mockStorage.read(key: StorageKeys.kUserToken));
//       },
//     );
//
//     test(
//       'getAccessToken reads from storage when in-memory cache is empty',
//       () async {
//         when(
//           () => mockStorage.read(key: StorageKeys.kUserToken),
//         ).thenAnswer((_) async => 'stored_token');
//
//         final result = await service.getAccessToken();
//
//         expect(result, 'stored_token');
//         verify(() => mockStorage.read(key: StorageKeys.kUserToken)).called(1);
//
//         // Second read should hit in-memory cache without calling storage again
//         final secondResult = await service.getAccessToken();
//         expect(secondResult, 'stored_token');
//         verifyNoMoreInteractions(mockStorage);
//       },
//     );
//   });
//
//   group('TokenStorageServiceImpl - Refresh Token', () {
//     test(
//       'saveRefreshToken with persist: true writes to storage and updates memory cache',
//       () async {
//         when(
//           () => mockStorage.write(
//             key: any(named: 'key'),
//             value: any(named: 'value'),
//           ),
//         ).thenAnswer((_) async {});
//
//         await service.saveRefreshToken('refresh_123', persist: true);
//
//         verify(
//           () => mockStorage.write(
//             key: StorageKeys.kRefreshToken,
//             value: 'refresh_123',
//           ),
//         ).called(1);
//         final cachedToken = await service.getRefreshToken();
//         expect(cachedToken, 'refresh_123');
//         verifyNever(() => mockStorage.read(key: StorageKeys.kRefreshToken));
//       },
//     );
//
//     test(
//       'saveRefreshToken with persist: false deletes key from storage and updates memory cache',
//       () async {
//         when(
//           () => mockStorage.delete(key: any(named: 'key')),
//         ).thenAnswer((_) async {});
//
//         await service.saveRefreshToken('refresh_session', persist: false);
//
//         verify(
//           () => mockStorage.delete(key: StorageKeys.kRefreshToken),
//         ).called(1);
//         final cachedToken = await service.getRefreshToken();
//         expect(cachedToken, 'refresh_session');
//         verifyNever(() => mockStorage.read(key: StorageKeys.kRefreshToken));
//       },
//     );
//
//     test(
//       'getRefreshToken reads from storage when in-memory cache is empty',
//       () async {
//         when(
//           () => mockStorage.read(key: StorageKeys.kRefreshToken),
//         ).thenAnswer((_) async => 'stored_refresh');
//
//         final result = await service.getRefreshToken();
//
//         expect(result, 'stored_refresh');
//         verify(
//           () => mockStorage.read(key: StorageKeys.kRefreshToken),
//         ).called(1);
//
//         // Second read hits in-memory cache
//         final secondResult = await service.getRefreshToken();
//         expect(secondResult, 'stored_refresh');
//         verifyNoMoreInteractions(mockStorage);
//       },
//     );
//   });
//
//   group('TokenStorageServiceImpl - Remembered Email', () {
//     test('saveRememberedEmail writes email to storage', () async {
//       when(
//         () => mockStorage.write(
//           key: any(named: 'key'),
//           value: any(named: 'value'),
//         ),
//       ).thenAnswer((_) async {});
//
//       await service.saveRememberedEmail('driver@flowery.com');
//
//       verify(
//         () => mockStorage.write(
//           key: StorageKeys.kRememberedEmail,
//           value: 'driver@flowery.com',
//         ),
//       ).called(1);
//     });
//
//     test('getRememberedEmail reads email from storage', () async {
//       when(
//         () => mockStorage.read(key: StorageKeys.kRememberedEmail),
//       ).thenAnswer((_) async => 'driver@flowery.com');
//
//       final result = await service.getRememberedEmail();
//
//       expect(result, 'driver@flowery.com');
//       verify(
//         () => mockStorage.read(key: StorageKeys.kRememberedEmail),
//       ).called(1);
//     });
//
//     test('deleteRememberedEmail deletes email from storage', () async {
//       when(
//         () => mockStorage.delete(key: any(named: 'key')),
//       ).thenAnswer((_) async {});
//
//       await service.deleteRememberedEmail();
//
//       verify(
//         () => mockStorage.delete(key: StorageKeys.kRememberedEmail),
//       ).called(1);
//     });
//   });
//
//   group('TokenStorageServiceImpl - clear', () {
//     test(
//       'clear resets in-memory cache and deletes token keys from storage',
//       () async {
//         when(
//           () => mockStorage.write(
//             key: any(named: 'key'),
//             value: any(named: 'value'),
//           ),
//         ).thenAnswer((_) async {});
//         when(
//           () => mockStorage.delete(key: any(named: 'key')),
//         ).thenAnswer((_) async {});
//         when(
//           () => mockStorage.read(key: any(named: 'key')),
//         ).thenAnswer((_) async => null);
//
//         // Populate memory cache
//         await service.saveAccessToken('token', persist: true);
//         await service.saveRefreshToken('refresh', persist: true);
//
//         // Clear tokens
//         await service.clear();
//
//         verify(() => mockStorage.delete(key: StorageKeys.kUserToken)).called(1);
//         verify(
//           () => mockStorage.delete(key: StorageKeys.kRefreshToken),
//         ).called(1);
//         verifyNever(
//           () => mockStorage.delete(key: StorageKeys.kRememberedEmail),
//         );
//
//         // In-memory cache must be null, forcing a read to storage
//         await service.getAccessToken();
//         verify(() => mockStorage.read(key: StorageKeys.kUserToken)).called(1);
//
//         await service.getRefreshToken();
//         verify(
//           () => mockStorage.read(key: StorageKeys.kRefreshToken),
//         ).called(1);
//       },
//     );
//   });
// }
