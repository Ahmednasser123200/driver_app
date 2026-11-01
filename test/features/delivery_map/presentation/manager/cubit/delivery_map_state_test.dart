import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('DeliveryMapState', () {
    test('default constructor has correct values', () {
      const state = DeliveryMapState();

      expect(state.target, DeliveryMapTarget.pickup);
      expect(state.driverPosition, DeliveryMapState.defaultDriverPosition);
      expect(state.pickupAddress, DeliveryMapState.defaultPickup);
      expect(state.userAddress, DeliveryMapState.defaultUser);
      expect(state.isLoading, isFalse);
      expect(state.isTrackingLocation, isFalse);
      expect(state.hasLocationPermission, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.markers, isEmpty);
      expect(state.polylines, isEmpty);
      expect(state.activeDestinationAddress, DeliveryMapState.defaultPickup);
      expect(
        state.destinationLatLng,
        LatLng(
          DeliveryMapState.defaultPickup.latitude,
          DeliveryMapState.defaultPickup.longitude,
        ),
      );
    });

    test('activeDestinationAddress returns userAddress when target is user', () {
      const state = DeliveryMapState(target: DeliveryMapTarget.user);

      expect(state.activeDestinationAddress, DeliveryMapState.defaultUser);
      expect(
        state.destinationLatLng,
        LatLng(
          DeliveryMapState.defaultUser.latitude,
          DeliveryMapState.defaultUser.longitude,
        ),
      );
    });

    test('copyWith updates specified fields and preserves others', () {
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
      const newPos = LatLng(12.0, 22.0);
      const marker = Marker(markerId: MarkerId('m1'));
      const polyline = Polyline(polylineId: PolylineId('p1'));

      final updated = initialState.copyWith(
        target: DeliveryMapTarget.user,
        driverPosition: newPos,
        pickupAddress: customPickup,
        userAddress: customUser,
        isLoading: true,
        isTrackingLocation: true,
        hasLocationPermission: true,
        errorMessage: 'An error',
        markers: {marker},
        polylines: {polyline},
      );

      expect(updated.target, DeliveryMapTarget.user);
      expect(updated.driverPosition, newPos);
      expect(updated.pickupAddress, customPickup);
      expect(updated.userAddress, customUser);
      expect(updated.isLoading, isTrue);
      expect(updated.isTrackingLocation, isTrue);
      expect(updated.hasLocationPermission, isTrue);
      expect(updated.errorMessage, 'An error');
      expect(updated.markers, {marker});
      expect(updated.polylines, {polyline});

      final clearedError = updated.copyWith(clearErrorMessage: true);
      expect(clearedError.errorMessage, isNull);
    });

    test('equality and props work properly', () {
      const state1 = DeliveryMapState();
      const state2 = DeliveryMapState();

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1.props, equals(state2.props));

      final state3 = state1.copyWith(isLoading: true);
      expect(state1, isNot(equals(state3)));
    });
  });
}
