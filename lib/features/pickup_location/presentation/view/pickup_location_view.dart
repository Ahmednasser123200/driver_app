import 'package:driver_app/features/pickup_location/presentation/widgets/location_addresses_panel.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/pickup_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/go_pack_button.dart';

class PickupLocationView extends StatelessWidget {
  const PickupLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final pickup = const LatLng(30.0444, 31.2357);
    final user = const LatLng(30.0398, 31.2302);

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(child: GoPackButton()),
          ),
          Column(
          children: [
            Expanded(
              flex: 6,
              child: PickupMap(pickupLocation: pickup, userLocation: user),
            ),
            Expanded(
              flex: 4,
              child: LocationAddressesPanel(
                userName: 'Nour mohamed',
                userAddress: '20th st, Sheikh Zayed, Giza',
                storeName: 'Flowery store',
                storeAddress: '20th st, Sheikh Zayed, Giza',
              ),
            ),
          ],
        ),]
      ),
    );
  }
}
