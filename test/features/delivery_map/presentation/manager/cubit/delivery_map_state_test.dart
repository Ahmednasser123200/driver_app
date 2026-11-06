import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryMapState', () {
    test('default constructor has null addresses and driverPosition', () {
      const state = DeliveryMapState();

      expect(state.target, DeliveryMapTarget.pickup);
      expect(state.driverPosition, isNull);
      expect(state.pickupAddress, isNull);
      expect(state.userAddress, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isTrackingLocation, isFalse);
      expect(state.hasLocationPermission, isFalse);
      expect(state.isRouteLoading, isFalse);
      expect(state.routeFailure, isNull);
      expect(state.hasRouteFailure, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.route, isNull);
      expect(state.activeDestinationAddress, isNull);
      expect(state.destinationPosition, isNull);
    });

    test('activeDestinationAddress and destinationPosition resolve based on target', () {
      const customPickup = AddressModel(
        title: 'Store',
        addressLine: 'Store St',
        latitude: 30.0131,
        longitude: 31.2089,
      );
      const customUser = AddressModel(
        title: 'User',
        addressLine: 'User St',
        latitude: 30.0250,
        longitude: 31.2200,
      );

      const pickupState = DeliveryMapState(
        target: DeliveryMapTarget.pickup,
        pickupAddress: customPickup,
        userAddress: customUser,
      );
      expect(pickupState.activeDestinationAddress, customPickup);
      expect(
        pickupState.destinationPosition,
        const GeoPoint(latitude: 30.0131, longitude: 31.2089),
      );

      const userState = DeliveryMapState(
        target: DeliveryMapTarget.user,
        pickupAddress: customPickup,
        userAddress: customUser,
      );
      expect(userState.activeDestinationAddress, customUser);
      expect(
        userState.destinationPosition,
        const GeoPoint(latitude: 30.0250, longitude: 31.2200),
      );
    });

    test('copyWith updates specified fields and supports clearing nullable fields', () {
      const initialState = DeliveryMapState();

      const customPickup = AddressModel(
        title: 'Custom Store',
        addressLine: 'Custom St',
        latitude: 10.0,
        longitude: 20.0,
        phoneNumber: '123',
      );
      const customUser = AddressModel(
        title: 'Custom Customer',
        addressLine: 'User St',
        latitude: 11.0,
        longitude: 21.0,
        phoneNumber: '456',
      );
      const newPos = GeoPoint(latitude: 12.0, longitude: 22.0);
      const sampleRoute = RouteModel(
        points: <GeoPoint>[newPos],
        distanceMeters: 500,
        durationSeconds: 60,
      );

      final updated = initialState.copyWith(
        target: DeliveryMapTarget.user,
        driverPosition: newPos,
        pickupAddress: customPickup,
        userAddress: customUser,
        isLoading: true,
        isTrackingLocation: true,
        hasLocationPermission: true,
        isRouteLoading: true,
        routeFailure: const InternetConnectionFailure(),
        errorMessage: 'An error',
        route: sampleRoute,
      );

      expect(updated.target, DeliveryMapTarget.user);
      expect(updated.driverPosition, newPos);
      expect(updated.pickupAddress, customPickup);
      expect(updated.userAddress, customUser);
      expect(updated.isLoading, isTrue);
      expect(updated.isTrackingLocation, isTrue);
      expect(updated.hasLocationPermission, isTrue);
      expect(updated.isRouteLoading, isTrue);
      expect(updated.routeFailure, isA<InternetConnectionFailure>());
      expect(updated.hasRouteFailure, isTrue);
      expect(updated.errorMessage, 'An error');
      expect(updated.route, sampleRoute);

      final cleared = updated.copyWith(
        clearDriverPosition: true,
        clearRouteFailure: true,
        clearErrorMessage: true,
        clearRoute: true,
      );
      expect(cleared.driverPosition, isNull);
      expect(cleared.routeFailure, isNull);
      expect(cleared.hasRouteFailure, isFalse);
      expect(cleared.errorMessage, isNull);
      expect(cleared.route, isNull);
    });

    test('equality and props work properly', () {
      const state1 = DeliveryMapState();
      const state2 = DeliveryMapState();

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1.props, equals(state2.props));
    });
  });
}
