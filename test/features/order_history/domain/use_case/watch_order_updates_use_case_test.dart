import 'package:driver_app/features/order_history/domain/use_case/watch_order_updates_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockOrderHistoryRepo mockRepo;
  late WatchOrderUpdatesUseCase useCase;

  setUp(() {
    mockRepo = MockOrderHistoryRepo();
    useCase = WatchOrderUpdatesUseCase(mockRepo);
  });

  test('delegates watchOrderUpdates to repo', () {
    when(() => mockRepo.watchOrderUpdates()).thenAnswer((_) => const Stream.empty());

    final stream = useCase.execute();

    verify(() => mockRepo.watchOrderUpdates()).called(1);
    expect(stream, isA<Stream>());
  });
}
