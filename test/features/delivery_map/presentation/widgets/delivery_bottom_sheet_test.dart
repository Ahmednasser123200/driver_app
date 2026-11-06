import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/services/url_launcher/url_launcher_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/check_location_permission_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_current_driver_location_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_route_use_case.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/widget_harness.dart';

class MockGetDriverLocationStreamUseCase extends Mock
    implements GetDriverLocationStreamUseCase {}

class MockCheckLocationPermissionUseCase extends Mock
    implements CheckLocationPermissionUseCase {}

class MockGetCurrentDriverLocationUseCase extends Mock
    implements GetCurrentDriverLocationUseCase {}

class MockGetRouteUseCase extends Mock implements GetRouteUseCase {}

class MockUrlLauncherService extends Mock implements UrlLauncherService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GeoPoint(latitude: 0, longitude: 0));
  });

  late MockGetDriverLocationStreamUseCase mockLocationStreamUseCase;
  late MockCheckLocationPermissionUseCase mockCheckPermissionUseCase;
  late MockGetCurrentDriverLocationUseCase mockGetCurrentLocationUseCase;
  late MockGetRouteUseCase mockGetRouteUseCase;
  late MockUrlLauncherService mockUrlLauncherService;
  late DeliveryMapCubit cubit;

  const samplePickup = AddressModel(
    title: 'Flowery store',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0131,
    longitude: 31.2089,
    phoneNumber: '+201000000000',
  );

  const sampleUser = AddressModel(
    title: 'Nour mohamed',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0250,
    longitude: 31.2200,
    phoneNumber: '+201011111111',
  );

  const sampleRoute = RouteModel(
    points: <GeoPoint>[
      GeoPoint(latitude: 30.0, longitude: 31.0),
      GeoPoint(latitude: 30.1, longitude: 31.1),
    ],
    distanceMeters: 2500.0,
    durationSeconds: 360.0,
  );

  setUp(() {
    mockLocationStreamUseCase = MockGetDriverLocationStreamUseCase();
    mockCheckPermissionUseCase = MockCheckLocationPermissionUseCase();
    mockGetCurrentLocationUseCase = MockGetCurrentDriverLocationUseCase();
    mockGetRouteUseCase = MockGetRouteUseCase();
    mockUrlLauncherService = MockUrlLauncherService();

    when(() => mockLocationStreamUseCase.call()).thenAnswer(
      (_) => const Stream<BaseResponse<UserLocationEntity>>.empty(),
    );
    when(() => mockCheckPermissionUseCase.call()).thenAnswer((_) async => true);
    when(() => mockGetCurrentLocationUseCase.call()).thenAnswer(
      (_) async => Success(
        UserLocationEntity(
          latitude: 30.0190,
          longitude: 31.2140,
          timestamp: DateTime.utc(2026, 11, 3),
        ),
      ),
    );
    when(
      () => mockGetRouteUseCase.call(
        origin: any(named: 'origin'),
        destination: any(named: 'destination'),
      ),
    ).thenAnswer((_) async => const Success(sampleRoute));

    cubit = DeliveryMapCubit(
      getDriverLocationStreamUseCase: mockLocationStreamUseCase,
      checkLocationPermissionUseCase: mockCheckPermissionUseCase,
      getCurrentDriverLocationUseCase: mockGetCurrentLocationUseCase,
      getRouteUseCase: mockGetRouteUseCase,
      urlLauncherService: mockUrlLauncherService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('DeliveryBottomSheet', () {
    testWidgets('renders both sections with pickup first by default', (tester) async {
      useDesignSurface(tester);

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
          initialTarget: DeliveryMapTarget.pickup,
        ),
      );

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

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
          initialTarget: DeliveryMapTarget.user,
        ),
      );

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

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
        ),
      );

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

    testWidgets('renders localized Route unavailable badge when route fails', (tester) async {
      useDesignSurface(tester);

      when(
        () => mockGetRouteUseCase.call(
          origin: any(named: 'origin'),
          destination: any(named: 'destination'),
        ),
      ).thenAnswer((_) async => const Error(InternetConnectionFailure()));

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
        ),
      );

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider.value(
            value: cubit,
            child: const DeliveryBottomSheet(),
          ),
        ),
      );

      expect(find.text('Route unavailable'), findsOneWidget);
    });
  });
}
