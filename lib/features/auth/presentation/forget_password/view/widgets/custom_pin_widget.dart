import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../manager/cubit/forget_password_cubit.dart';
import '../../manager/cubit/forget_password_event.dart';
import '../../manager/cubit/forget_password_state.dart';
import 'otp_pin_theme.dart';

class CustomPinWidget extends StatelessWidget {
  const CustomPinWidget({
    super.key,
    required this.email,
    required this.codeController,
    required this.textTheme,
    required this.state,
  });

  final String email;
  final TextEditingController codeController;
  final TextTheme textTheme;
  final ForgetPasswordState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ForgetPasswordCubit>();
    final failure = state.otpState.failure;
    final errorMessage = failure == null
        ? ''
        : mapAppFailureToMessage(failure, l10n);
    final hasError = failure != null;
    final isLockedOut = state.isOtpLockedOut;

    return Column(
      children: [
        Pinput(
          controller: codeController,
          enabled: !isLockedOut,
          onCompleted: isLockedOut
              ? null
              : (value) {
                  cubit.doEvent(VerifyOtpEvent(otpCode: value, email: email));
                },
          forceErrorState: hasError,
          errorPinTheme: OtpPinTheme.themeErrorPin(textTheme),
          animationCurve: Curves.bounceInOut,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          cursor: Container(width: 2, height: 30, color: AppColors.pinkBase),
          length: 6,
          keyboardType: TextInputType.number,
          disabledPinTheme: OtpPinTheme.themeDisabledPin(textTheme),
          submittedPinTheme: OtpPinTheme.themeSubmittedPin(textTheme),
          focusedPinTheme: OtpPinTheme.themeFocusedPin(textTheme),
          defaultPinTheme: OtpPinTheme.themeDefaultPin(textTheme),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.error_outline_outlined,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        if (isLockedOut)
          Column(
            children: [
              Text(
                l10n.otpMaxAttemptsReached,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 12),
              _ActionLink(
                text: l10n.requestNewCode,
                textTheme: textTheme,
                onTap: () {
                  cubit.doEvent(ResendOtpEvent(email: email));
                },
              ),
            ],
          )
        else ...[
          Text(
            l10n.otpAttemptsRemaining(state.verifyAttemptsRemaining),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.black.withValues(alpha: 0.54),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${l10n.didntReceiveCode} ', style: textTheme.bodyLarge),
              if (state.canResendOtp)
                _ActionLink(
                  text: l10n.resendAvailable,
                  textTheme: textTheme,
                  onTap: () {
                    cubit.doEvent(ResendOtpEvent(email: email));
                  },
                )
              else
                BlocSelector<ForgetPasswordCubit, ForgetPasswordState, int>(
                  selector: (state) => state.resendSecondsRemaining,
                  builder: (context, secondsRemaining) {
                    return Text(
                      l10n.resendInSeconds(secondsRemaining),
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.black.withValues(alpha: 0.54),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({
    required this.text,
    required this.textTheme,
    required this.onTap,
  });

  final String text;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.pinkBase,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.pinkBase,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
