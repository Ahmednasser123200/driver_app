import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/custom_text_form_field.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<ForgetPasswordCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.forgetPasswordTitle)),
        body:
            BaseUiEventListener<
              ForgetPasswordCubit,
              ForgetPasswordState,
              BaseUiEvent
            >(
              child: BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 50.h),
                          Center(child: Text(l10n.forgetPasswordTitle)),
                          SizedBox(height: 10.h),
                          Text(
                            l10n.forgetPasswordDescription,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          CustomTextFormField(
                            controller: _emailController,
                            label: l10n.email,
                            hint: l10n.enterEmail,
                            validator: AuthValidators.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 30.h),
                          CustomButton(
                            isLoading: state.forgotstate.isLoading,
                            label: l10n.confirmButton,
                            enabled: !state.forgotstate.isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ForgetPasswordCubit>().doEvent(
                                  ForgetBassEvent(
                                    email: _emailController.text.trim(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}
