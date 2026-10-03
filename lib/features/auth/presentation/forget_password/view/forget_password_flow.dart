import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/forget_password_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/reset_password_view.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/verification_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetPasswordFlow extends StatefulWidget {
  const ForgetPasswordFlow({super.key});

  @override
  State<ForgetPasswordFlow> createState() => _ForgetPasswordFlowState();
}

class _ForgetPasswordFlowState extends State<ForgetPasswordFlow> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToVerification() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToReset() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgetPasswordCubit>(),
      child:
          BaseUiEventListener<
            ForgetPasswordCubit,
            ForgetPasswordState,
            BaseUiEvent
          >(
            onCustomEvent: (context, event) {
              if (event is ForgetPasswordGoToVerification) {
                _goToVerification();
                return;
              }
              if (event is ForgetPasswordGoToReset) {
                _goToReset();
                return;
              }
            },
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ForgetPasswordView(),
                VerificationView(),
                ResetPasswordView(),
              ],
            ),
          ),
    );
  }
}
