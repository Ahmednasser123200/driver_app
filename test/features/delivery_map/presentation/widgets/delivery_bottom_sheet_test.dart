import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/core/services/location/location_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_route_use_case.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/widget_harness.dart';

class MockLocationService extends Mock implements LocationService {}

class MockGetDriverLocationStreamUseCase extends Mock
    implements GetDriverLocationStreamUseCase {}

class MockGetRouteUseCase extends Mock implements GetRouteUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  late MockLocationService mockLocationService;
  late MockGetDriverLocationStreamUseCase mockLocationStreamUseCase;
  late MockGetRouteUseCase mockGetRouteUseCase;
  late DeliveryMapCubit cubit;

  const sampleRoute = RouteModel(
    points: <LatLng>[LatLng(30.0, 31.0), LatLng(30.1, 31.1)],
    distanceMeters: 2500.0,
    durationSeconds: 360.0,
  );

  setUp(() {
    mockLocationService = MockLocationService();
    mockLocationStreamUseCase = MockGetDriverLocationStreamUseCase();
    mockGetRouteUseCase = MockGetRouteUseCase();

    when(() => mockLocationStreamUseCase.call())
        .thenAnswer((_) => const Stream<Position>.empty());
    when(() => mockLocationService.checkAndRequestPermission())
        .thenAnswer((_) async => true);
    when(() => mockLocationService.getCurrentPosition())
        .thenAnswer((_) async => null);
    when(
      () => mockGetRouteUseCase.call(
        origin: any(named: 'origin'),
        destination: any(named: 'destination'),
      ),
    ).thenAnswer((_) async => const Success(sampleRoute));

    cubit = DeliveryMapCubit(
      getDriverLocationStreamUseCase: mockLocationStreamUseCase,
      locationService: mockLocationService,
      getRouteUseCase: mockGetRouteUseCase,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('DeliveryBottomSheet', () {
    testWidgets('renders both sections with pickup first by default', (tester) async {
      useDesignSurface(tester);

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider.value(
            value: cubit,
            child: const DeliveryBottomSheet(),
          ),
        ),
      );

      expect(find.text('Pickup address'), findsOneWidget);
      expect(find.text('User address'), findsOneWidget);
      expect(find.text('Flowery store'), findsOneWidget);
      expect(find.text('Nour mohamed'), findsOneWidget);
    });

    testWidgets('renders user address first when target is user', (tester) async {
      useDesignSurface(tester);

      await cubit.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider.value(
            value: cubit,
            child: const DeliveryBottomSheet(),
          ),
        ),
      );

      final userFinder = find.text('User address');
      final pickupFinder = find.text('Pickup address');

      expect(userFinder, findsOneWidget);
      expect(pickupFinder, findsOneWidget);

      final userTop = tester.getTopLeft(userFinder).dy;
      final pickupTop = tester.getTopLeft(pickupFinder).dy;

      expect(userTop, lessThan(pickupTop));
    });

    testWidgets('renders route distance and duration badge when route is present', (tester) async {
      useDesignSurface(tester);

      await cubit.doEvent(const InitDeliveryMapEvent());

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider.value(
            value: cubit,
            child: const DeliveryBottomSheet(),
          ),
        ),
      );

      expect(find.text('2.5 km • 6 min'), findsOneWidget);
    });
  });
}
