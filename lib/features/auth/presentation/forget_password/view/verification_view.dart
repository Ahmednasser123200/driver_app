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
  const VerificationView({super.key, required this.email, required this.cubit});

  final String email;
  final ForgetPasswordCubit cubit;

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

    return BlocProvider.value(
      value: widget.cubit..startResendCooldown(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.emailVerificationTitle)),
        body:
            BaseUiEventListener<
              ForgetPasswordCubit,
              ForgetPasswordState,
              BaseUiEvent
            >(
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
                      SizedBox(height: 40.h),
                      Text(
                        l10n.emailVerificationTitle,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 34.w),
                        child: Text(
                          l10n.emailVerificationDescription,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _buildPinWidget(textTheme),
                    ],
                  ),
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
          previous.isOtpLockedOut != current.isOtpLockedOut ||
          previous.verifyAttemptsRemaining != current.verifyAttemptsRemaining ||
          previous.resendSecondsRemaining != current.resendSecondsRemaining ||
          previous.canResendOtp != current.canResendOtp,
      builder: (context, state) {
        return CustomPinWidget(
          email: widget.email,
          codeController: _codeController,
          textTheme: textTheme,
          state: state,
        );
      },
    );
  }
}
