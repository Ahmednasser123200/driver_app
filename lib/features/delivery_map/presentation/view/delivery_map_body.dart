import 'dart:async';
import 'dart:math';

import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/delivery_map/presentation/utils/map_marker_generator.dart';
import 'package:driver_app/features/delivery_map/presentation/utils/polyline_helper.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_map_back_button.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
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
  static const LatLng _fallbackCameraTarget = LatLng(30.0444, 31.2357);

  GoogleMapController? _mapController;
  StreamSubscription<DeliveryMapUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _uiEventSubscription = context
        .read<DeliveryMapCubit>()
        .uiEventStream
        .listen(_onUiEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _warmUpMarkerIcons();
  }

  void _onUiEvent(DeliveryMapUiEvent event) {
    if (!mounted) return;
    if (event is DeliveryMapFitBounds) {
      _fitBounds(context.read<DeliveryMapCubit>().state);
    }
  }

  Future<void> _warmUpMarkerIcons() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    await Future.wait([
      MapMarkerGenerator.createPillMarker(
        label: l10n.yourLocation,
        icon: Icons.navigation_rounded,
      ),
      MapMarkerGenerator.createPillMarker(
        label: l10n.flowery,
        icon: Icons.local_florist_rounded,
      ),
      MapMarkerGenerator.createPillMarker(
        label: l10n.user,
        icon: Icons.person_rounded,
      ),
    ]);

    if (mounted) {
      setState(() {});
    }
  }

  Set<Marker> _buildMarkers(DeliveryMapState state, AppLocalizations l10n) {
    final markers = <Marker>{};
    final driverPos = state.driverPosition;
    final destPos = state.destinationPosition;
    final isPickup = state.target.isPickup;

    if (driverPos != null) {
      final driverIcon =
          MapMarkerGenerator.getCachedPillMarker(
            label: l10n.yourLocation,
            icon: Icons.navigation_rounded,
          ) ??
          BitmapDescriptor.defaultMarker;

      markers.add(
        Marker(
          markerId: const MarkerId('driver_marker'),
          position: PolylineHelper.toLatLng(driverPos),
          icon: driverIcon,
          infoWindow: InfoWindow(title: l10n.yourLocation),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    if (destPos != null) {
      final destLabel = isPickup ? l10n.flowery : l10n.user;
      final destIconData = isPickup
          ? Icons.local_florist_rounded
          : Icons.person_rounded;
      final destIcon =
          MapMarkerGenerator.getCachedPillMarker(
            label: destLabel,
            icon: destIconData,
          ) ??
          BitmapDescriptor.defaultMarker;

      markers.add(
        Marker(
          markerId: MarkerId(isPickup ? 'pickup_marker' : 'user_marker'),
          position: PolylineHelper.toLatLng(destPos),
          icon: destIcon,
          infoWindow: InfoWindow(
            title: state.activeDestinationAddress?.title ?? destLabel,
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(DeliveryMapState state) {
    final driverPos = state.driverPosition;
    final destPos = state.destinationPosition;
    final routePoints = state.route?.points;

    if ((routePoints == null || routePoints.isEmpty) &&
        (driverPos == null || destPos == null)) {
      return const <Polyline>{};
    }

    final polyline = PolylineHelper.buildRoutePolyline(
      id: 'active_delivery_route',
      geoPoints: routePoints,
      start: driverPos != null ? PolylineHelper.toLatLng(driverPos) : null,
      end: destPos != null ? PolylineHelper.toLatLng(destPos) : null,
    );

    return <Polyline>{polyline};
  }

  void _fitBounds(DeliveryMapState state) {
    if (_mapController == null) return;

    final driverPos = state.driverPosition;
    final destPos = state.destinationPosition;
    if (driverPos == null && destPos == null) return;

    final seed = driverPos ?? destPos!;
    double minLat = seed.latitude;
    double maxLat = seed.latitude;
    double minLng = seed.longitude;
    double maxLng = seed.longitude;

    if (destPos != null) {
      minLat = min(minLat, destPos.latitude);
      maxLat = max(maxLat, destPos.latitude);
      minLng = min(minLng, destPos.longitude);
      maxLng = max(maxLng, destPos.longitude);
    }

    final points = state.route?.points;
    if (points != null && points.isNotEmpty) {
      for (final p in points) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 70),
      );
    } catch (_) {
      // Ignore camera update when the native map view is not laid out yet.
    }
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: BlocBuilder<DeliveryMapCubit, DeliveryMapState>(
            buildWhen: (previous, current) =>
                previous.target != current.target ||
                previous.driverPosition != current.driverPosition ||
                previous.pickupAddress != current.pickupAddress ||
                previous.userAddress != current.userAddress ||
                previous.route != current.route ||
                previous.routeFailure != current.routeFailure,
            builder: (context, state) {
              final initialTargetPoint =
                  state.driverPosition ?? state.destinationPosition;
              final initialTarget = initialTargetPoint != null
                  ? PolylineHelper.toLatLng(initialTargetPoint)
                  : _fallbackCameraTarget;

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 14.5,
                ),
                mapType: MapType.normal,
                markers: _buildMarkers(state, l10n),
                polylines: _buildPolylines(state),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _fitBounds(state);
                  });
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Align(
              alignment: AlignmentDirectional.topStart,
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
  }
}
