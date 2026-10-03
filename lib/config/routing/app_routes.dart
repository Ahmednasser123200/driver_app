import 'package:driver_app/config/di/di.dart';
import 'package:flutter/material.dart';

import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/forget_password_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/reset_password_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/verification_view.dart';

import 'routes.dart';

abstract final class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final cubit = getIt<ForgetPasswordCubit>();
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
          builder: (_) => ForgetPasswordView(cubit: cubit),
        );
      case Routes.verificationCode:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerificationView(
            email: _argString(settings.arguments, 'email'),
            cubit: cubit,
          ),
        );
      case Routes.resetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordView(
            email: _argString(settings.arguments, 'email'),
            otpcode: _argString(settings.arguments, 'otpcode'),
            cubit: cubit,
          ),
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

  static String _argString(Object? arguments, String key) {
    if (arguments is Map) {
      final value = arguments[key];
      if (value is String) return value;
      if (value != null) return value.toString();
    }
    return '';
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
