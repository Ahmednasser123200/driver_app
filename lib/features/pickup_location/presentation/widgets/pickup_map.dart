
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupMap extends StatelessWidget {
  const PickupMap({
    super.key,
    required this.pickupLocation,
    required this.userLocation,
  });

  final LatLng pickupLocation;
  final LatLng userLocation;

  static const Color routeColor = Color(0xFFE91E63);

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLocation,
        infoWindow: const InfoWindow(
          title: 'Pickup location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRose,
        ),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: userLocation,
        infoWindow: const InfoWindow(
          title: 'User location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: [
          pickupLocation,
          userLocation,
        ],
        color: routeColor,
        width: 4,
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: pickupLocation,
        zoom: 14,
      ),
      markers: markers,
      polylines: polylines,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
