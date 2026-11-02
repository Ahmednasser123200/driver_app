import 'package:driver_app/features/onboarding/screen/onboarding_view.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/login/view/login_view.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/shared/widgets/bottom_navigation_bar.dart';
import '../../features/order_history/presentation/view/order_history_details_view.dart';
import '../../features/order_history/presentation/view/orders_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/forget_password_flow.dart';

import '../../features/auth/presentation/apply/view/apply_success_view.dart';
import '../../features/auth/presentation/apply/view/apply_view.dart';
import 'routes.dart';

abstract final class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );

      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginView(),
        );

      case Routes.forgetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgetPasswordFlow(),
        );

      case Routes.apply:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ApplyView(),
        );

      case Routes.successApply:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ApplySuccessView(),
        );

      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppBottomNavigationBar(
            homeScreen: _StubScreen('Home'),
            ordersScreen: OrdersView(),
            profileScreen: _StubScreen('Profile'),
          ),
        );
      case Routes.ordersHistory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrdersView(),
        );
      case Routes.orderHistoryDetails:
        final args = settings.arguments;
        final orderId = args is String ? args : '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderHistoryDetailsView(orderId: orderId),
        );

      case Routes.orderDetails:
        final arguments = settings.arguments;
        if (arguments is! String || arguments.isEmpty) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) =>
                _StubScreen(AppLocalizations.of(context)!.invalidOrderId),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<OrderDetailsCubit>(),
            child: OrderDetailsView(orderId: arguments),
          ),
        );
      case Routes.tracking:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Tracking'),
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
