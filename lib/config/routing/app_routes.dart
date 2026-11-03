import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/view/delivery_map_view.dart';
import 'package:driver_app/features/order_details/presentation/extensions/address_model_extension.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'routes.dart';

abstract final class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Onboarding'),
        );
      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Login'),
        );
      case Routes.forgetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Forget Password'),
        );
      case Routes.verificationCode:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Verification Code'),
        );
      case Routes.resetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Reset Password'),
        );
      case Routes.apply:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Apply'),
        );
      case Routes.successApply:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Success Apply'),
        );
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Home'),
        );
      case Routes.orders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Orders'),
        );
      case Routes.pickupLocation:
        AddressModel? pickupAddress;
        AddressModel? userAddress;
        final args = settings.arguments;
        if (args is OrderDetailsCubit) {
          final data = args.state.orderDetails.data;
          if (data != null) {
            pickupAddress = data.pickupAddress.toAddressModel();
            userAddress = data.userAddress.toAddressModel();
          }
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeliveryMapCubit>(),
            child: DeliveryMapView(
              pickupAddress: pickupAddress,
              userAddress: userAddress,
              initialTarget: DeliveryMapTarget.pickup,
            ),
          ),
        );
      case Routes.orderDetails:
        final orderId = _resolveOrderId(settings);

        if (orderId == null || orderId.isEmpty) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final colorScheme = Theme.of(context).colorScheme;
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.orderDetails),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.invalidOrderId,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<OrderDetailsCubit>(),
            child: OrderDetailsView(orderId: orderId),
          ),
        );
      case Routes.tracking:
        AddressModel? pickupAddress;
        AddressModel? userAddress;
        final args = settings.arguments;
        if (args is OrderDetailsCubit) {
          final data = args.state.orderDetails.data;
          if (data != null) {
            pickupAddress = data.pickupAddress.toAddressModel();
            userAddress = data.userAddress.toAddressModel();
          }
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<DeliveryMapCubit>(),
            child: DeliveryMapView(
              pickupAddress: pickupAddress,
              userAddress: userAddress,
              initialTarget: DeliveryMapTarget.user,
            ),
          ),
        );
      case Routes.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Profile'),
        );
      case Routes.editProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Edit Profile'),
        );
      case Routes.deliverySuccess:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Delivery Success'),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Not Found'),
        );
    }
  }

  static String? _resolveOrderId(RouteSettings settings) {
    final arguments = settings.arguments;

    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }

    if (arguments is Map) {
      final orderId = arguments['orderId'] ?? arguments['id'];
      if (orderId is String && orderId.trim().isNotEmpty) {
        return orderId.trim();
      }
    }

    if (arguments == null) {
      final defaultId = ApiStrings.defaultOrderId.trim();
      if (defaultId.isNotEmpty) {
        return defaultId;
      }
    }

    return null;
  }
}

class _StubScreen extends StatelessWidget {
  const _StubScreen(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
