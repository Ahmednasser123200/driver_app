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
  const ResetPasswordView({
    super.key,
    required this.email,
    required this.otpcode,
    required this.cubit,
  });

  final String email;
  final String otpcode;
  final ForgetPasswordCubit cubit;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final state = widget.cubit.state;
    if (state.otpState.data != null && state.otpState.data!.resetToken.isNotEmpty) {
      if (mounted) {
        setState(() => _isVerified = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
        body: BaseUiEventListener<
          ForgetPasswordCubit,
          ForgetPasswordState,
          BaseUiEvent
        >(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 50.h),
                    Center(
                      child: Text(
                        l10n.resetPasswordTitle,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      l10n.resetPasswordDescription,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    CustomTextFormField(
                      label: l10n.newPassword,
                      hint: l10n.enterPassword,
                      controller: _newPasswordController,
                      validator: AuthValidators.password,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    SizedBox(height: 20.h),
                    CustomTextFormField(
                      label: l10n.confirmPassword,
                      hint: l10n.confirmPassword,
                      controller: _confirmPasswordController,
                      validator: (value) =>
                          AuthValidators.confirmPassword(
                            value,
                            _newPasswordController.text,
                          ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    SizedBox(height: 30.h),
                    _buildResetButton(l10n),
                  ],
                ),
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
          previous.resetState.isLoading != current.resetState.isLoading,
      builder: (context, state) {
        return CustomButton(
          isLoading: state.resetState.isLoading,
          label: l10n.updateButton,
          enabled: !state.resetState.isLoading && _isVerified,
          onPressed: _isVerified
              ? () {
                  if (_formKey.currentState!.validate()) {
                    context.read<ForgetPasswordCubit>().doEvent(
                      ResetPasswordEvent(
                        email: widget.email,
                        newPassword: _newPasswordController.text,
                        resetCode: widget.otpcode,
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
