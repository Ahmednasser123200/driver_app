import 'package:driver_app/features/onboarding/screen/onboarding_view.dart';
import 'package:flutter/material.dart';

import '../../core/shared/widgets/bottom_navigation_bar.dart';
import '../../features/order_history/presentation/view/order_details_view.dart';
import '../../features/order_history/presentation/view/orders_view.dart';
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
          builder: (_) => const AppBottomNavigationBar(
            homeScreen: _StubScreen('Home'),
            ordersScreen: OrdersView(),
            profileScreen: _StubScreen('Profile'),
            initialIndex: 0,
          ),
        );
      case Routes.orders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppBottomNavigationBar(
            homeScreen: _StubScreen('Home'),
            ordersScreen: OrdersView(),
            profileScreen: _StubScreen('Profile'),
            initialIndex: 1,
          ),
        );
      case Routes.orderDetails:
        final orderId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderDetailsView(orderId: orderId),
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
