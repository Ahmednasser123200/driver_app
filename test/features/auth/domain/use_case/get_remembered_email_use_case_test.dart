import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/get_remembered_email_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late GetRememberedEmailUseCase useCase;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = GetRememberedEmailUseCase(mockAuthRepo);
  });

  group('GetRememberedEmailUseCase', () {
    test('returns remembered email from repository', () async {
      when(
        () => mockAuthRepo.loadRememberedEmail(),
      ).thenAnswer((_) async => 'driver@test.com');

      final result = await useCase();

      expect(result, equals('driver@test.com'));
      verify(() => mockAuthRepo.loadRememberedEmail()).called(1);
    });

    test('returns null when no remembered email is stored', () async {
      when(
        () => mockAuthRepo.loadRememberedEmail(),
      ).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isNull);
      verify(() => mockAuthRepo.loadRememberedEmail()).called(1);
    });
  });
}
