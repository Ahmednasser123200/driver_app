import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/features/auth/presentation/forget_password/view/widgets/custom_pin_widget.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _clearOtpField() => _codeController.clear();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emailVerificationTitle)),
      body:
      BaseUiEventListener<
          ForgetPasswordCubit,
          ForgetPasswordState,
          BaseUiEvent
      >(
        cubit: context.read<ForgetPasswordCubit>(),
        onCustomEvent: (context, event) {
          if (event is ClearOtpField) {
            _clearOtpField();
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  l10n.emailVerificationTitle,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 34.w),
                  child: Text(
                    l10n.emailVerificationDescription,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPinWidget(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinWidget(TextTheme textTheme) {
    return BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
      buildWhen: (previous, current) =>
      previous.otpState != current.otpState ||
          previous.canResendOtp != current.canResendOtp ||
          previous.email != current.email,
      builder: (context, state) {
        return CustomPinWidget(
          email: state.email,
          codeController: _codeController,
          textTheme: textTheme,
          state: state,
        );
      },
    );
  }
}