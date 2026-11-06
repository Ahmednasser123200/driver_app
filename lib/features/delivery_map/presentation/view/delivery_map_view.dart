import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/delivery_map/presentation/view/delivery_map_body.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryMapView extends StatefulWidget {
  final AddressModel? pickupAddress;
  final AddressModel? userAddress;
  final DeliveryMapTarget? initialTarget;

  const DeliveryMapView({
    super.key,
    this.pickupAddress,
    this.userAddress,
    this.initialTarget,
  });

  @override
  State<DeliveryMapView> createState() => _DeliveryMapViewState();
}

class _DeliveryMapViewState extends State<DeliveryMapView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<DeliveryMapCubit>().doEvent(
        InitDeliveryMapEvent(
          pickupAddress: widget.pickupAddress,
          userAddress: widget.userAddress,
          initialTarget: widget.initialTarget,
        ),
      );
    });
  }

  void _handleUiEvent(BuildContext context, DeliveryMapUiEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    switch (event) {
      case DeliveryMapLocationPermissionDenied():
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.locationPermissionToTrackDelivery),
            backgroundColor: AppColors.error,
          ),
        );

      case DeliveryMapLocationServiceDisabled():
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.enableGpsToTrackDelivery),
            backgroundColor: AppColors.error,
          ),
        );

      case DeliveryMapLaunchUrlFailed(:final url):
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotOpenUrl(url)),
            backgroundColor: AppColors.error,
          ),
        );

      case DeliveryMapFitBounds():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseUiEventListener<
      DeliveryMapCubit,
      DeliveryMapState,
      DeliveryMapUiEvent
    >(
      onCustomEvent: _handleUiEvent,
      child: const Scaffold(
        body: DeliveryMapBody(),
      ),
    );
  }
}
