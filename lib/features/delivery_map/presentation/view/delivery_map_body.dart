import 'dart:math';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_map_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryMapBody extends StatefulWidget {
  const DeliveryMapBody({super.key});

  @override
  State<DeliveryMapBody> createState() => _DeliveryMapBodyState();
}

class _DeliveryMapBodyState extends State<DeliveryMapBody> {
  GoogleMapController? _mapController;

  void _fitBounds(DeliveryMapState state) {
    if (_mapController == null) return;

    final driver = state.driverPosition;
    final dest = state.destinationLatLng;

    final southWest = LatLng(
      min(driver.latitude, dest.latitude),
      min(driver.longitude, dest.longitude),
    );
    final northEast = LatLng(
      max(driver.latitude, dest.latitude),
      max(driver.longitude, dest.longitude),
    );

    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);

    try {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 70),
      );
    } catch (_) {
      // In case map view is not yet rendered
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryMapCubit, DeliveryMapState>(
      listenWhen: (prev, curr) =>
          prev.target != curr.target ||
          prev.driverPosition != curr.driverPosition,
      listener: (context, state) {
        debugPrint('DeliveryMapBody listener: fitting bounds for target=${state.target}');
        _fitBounds(state);
      },
      builder: (context, state) {
        debugPrint('DeliveryMapBody builder: markers=${state.markers.length}, polylines=${state.polylines.length}, target=${state.target}');
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: state.driverPosition,
                  zoom: 14.5,
                ),
                mapType: MapType.normal,
                markers: state.markers,
                polylines: state.polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  debugPrint('DeliveryMapBody: onMapCreated called');
                  _mapController = controller;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _fitBounds(state);
                  });
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: DeliveryMapBackButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: DeliveryBottomSheet(),
            ),
          ],
        );
      },
    );
  }
}
