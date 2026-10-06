import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/application_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/application_dto.dart';

void main() {
  group('ApplicationResponseDto & ApplicationDto', () {
    test('ApplicationDto fromJson and toJson work correctly', () {
      final json = {
        'applicationId': 'app_123',
        'status': 'pending',
      };

      final dto = ApplicationDto.fromJson(json);

      expect(dto.applicationId, 'app_123');
      expect(dto.status, 'pending');

      final resultJson = dto.toJson();
      expect(resultJson['applicationId'], 'app_123');
      expect(resultJson['status'], 'pending');
    });

    test('ApplicationResponseDto fromJson and toJson work correctly', () {
      final json = {
        'success': true,
        'message': 'Success',
        'data': {
          'applicationId': 'app_123',
          'status': 'pending',
        },
      };

      final responseDto = ApplicationResponseDto.fromJson(json);

      expect(responseDto.success, true);
      expect(responseDto.message, 'Success');
      expect(responseDto.data?.applicationId, 'app_123');
      expect(responseDto.data?.status, 'pending');

      final resultJson = responseDto.toJson();
      expect(resultJson['success'], true);
      expect(resultJson['message'], 'Success');
      expect((resultJson['data'] as ApplicationDto).applicationId, 'app_123');
    });
  });
}
