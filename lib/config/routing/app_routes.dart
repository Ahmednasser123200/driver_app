import 'package:flutter/material.dart';

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
      case Routes.orderDetails:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _StubScreen('Order Details'),
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
