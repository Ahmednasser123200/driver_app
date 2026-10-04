import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/custom_text_form_field.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
      body:
      BaseUiEventListener<
          ForgetPasswordCubit,
          ForgetPasswordState,
          BaseUiEvent
      >(
        cubit: context.read<ForgetPasswordCubit>(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      l10n.resetPasswordTitle,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.resetPasswordDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: l10n.newPassword,
                    hint: l10n.enterPassword,
                    controller: _newPasswordController,
                    validator: AuthValidators.password,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: l10n.confirmPassword,
                    hint: l10n.confirmPassword,
                    controller: _confirmPasswordController,
                    validator: (value) => AuthValidators.confirmPassword(
                      value,
                      _newPasswordController.text,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  _buildResetButton(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(AppLocalizations l10n) {
    return BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
      buildWhen: (previous, current) =>
      previous.resetState.isLoading != current.resetState.isLoading ||
          previous.otpState != current.otpState ||
          previous.email != current.email,
      builder: (context, state) {
        final resetCode = state.otpState.data?.resetToken ?? '';
        final email = state.email;
        final canSubmit = email.isNotEmpty && resetCode.isNotEmpty;

        return CustomButton(
          isLoading: state.resetState.isLoading,
          label: l10n.updateButton,
          enabled: !state.resetState.isLoading && canSubmit,
          onPressed: canSubmit
              ? () {
            if (_formKey.currentState!.validate()) {
              context.read<ForgetPasswordCubit>().doEvent(
                ResetPasswordEvent(
                  email: email,
                  newPassword: _newPasswordController.text,
                  resetCode: resetCode,
                ),
              );
            }
          }
              : null,
        );
      },
    );
  }
}