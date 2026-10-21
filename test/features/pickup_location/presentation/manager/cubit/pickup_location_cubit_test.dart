import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/usecases/get_driving_route_use_case.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_cubit.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures.dart';

class MockGetDrivingRouteUseCase extends Mock
    implements GetDrivingRouteUseCase {}

void main() {
  late MockGetDrivingRouteUseCase useCase;
  late PickupLocationCubit cubit;

  setUp(() {
    useCase = MockGetDrivingRouteUseCase();
    cubit = PickupLocationCubit(useCase);

    registerFallbackValue(kDrivingRouteParams);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('emits a loading state followed by the loaded route', () async {
    when(
      () => useCase.execute(any()),
    ).thenAnswer((_) async => Success<DrivingRoute>(buildDrivingRoute()));

    final states = <PickupLocationState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.loadDrivingRoute(kDrivingRouteParams);
    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(2));
    expect(states.first.drivingRoute.isLoading, isTrue);
    expect(states.last.drivingRoute.isLoading, isFalse);
    expect(states.last.drivingRoute.data, equals(buildDrivingRoute()));
    expect(states.last.drivingRoute.failure, isNull);

    await subscription.cancel();
  });

  test('emits the failure and a failure message event on error', () async {
    when(
      () => useCase.execute(any()),
    ).thenAnswer((_) async => Error<DrivingRoute>(const UnknownFailure()));

    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);

    final states = <PickupLocationState>[];
    final stateSubscription = cubit.stream.listen(states.add);

    await cubit.loadDrivingRoute(kDrivingRouteParams);
    await Future<void>.delayed(Duration.zero);

    expect(states.last.drivingRoute.isLoading, isFalse);
    expect(states.last.drivingRoute.failure, isA<UnknownFailure>());
    expect(states.last.drivingRoute.data, isNull);

    expect(events, hasLength(1));
    expect(events.first, isA<ShowFailureMessage>());
    expect((events.first as ShowFailureMessage).failure, isA<UnknownFailure>());

    await stateSubscription.cancel();
    await subscription.cancel();
  });

  test('clears the previous failure when a new route is requested', () async {
    when(
      () => useCase.execute(any()),
    ).thenAnswer((_) async => Error<DrivingRoute>(const UnknownFailure()));

    await cubit.loadDrivingRoute(kDrivingRouteParams);

    when(
      () => useCase.execute(any()),
    ).thenAnswer((_) async => Success<DrivingRoute>(buildDrivingRoute()));

    final states = <PickupLocationState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.loadDrivingRoute(kDrivingRouteParams);
    await Future<void>.delayed(Duration.zero);

    expect(states.first.drivingRoute.isLoading, isTrue);
    expect(states.first.drivingRoute.failure, isNull);
    expect(states.last.drivingRoute.failure, isNull);
    expect(states.last.drivingRoute.data, equals(buildDrivingRoute()));

    await subscription.cancel();
  });
}
