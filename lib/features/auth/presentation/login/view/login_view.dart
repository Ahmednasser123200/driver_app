import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/localization/validation_error_message_mapper.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_intent.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<LoginCubit>()..handle(LoadSavedEmail()),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leadingWidth: 40.w,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.black,
              size: 20.w,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            AppStrings.login,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: BaseUiEventListener<LoginCubit, LoginState, BaseUiEvent>(
            child: BlocConsumer<LoginCubit, LoginState>(
              listenWhen: (prev, curr) =>
                  prev.email != curr.email && _emailController.text.isEmpty,
              listener: (context, state) {
                _emailController.text = state.email;
              },
              builder: (context, state) {
                final cubit = context.read<LoginCubit>();
                final isFormFilled =
                    state.email.trim().isNotEmpty && state.password.isNotEmpty;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field (Floating outline style matching Figma)
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => mapValidationErrorToMessage(
                            AuthValidators.email(value),
                            l10n,
                          ),
                          onChanged: (val) => cubit.handle(EmailChanged(val)),
                          decoration: InputDecoration(
                            labelText: AppStrings.email,
                            hintText: AppStrings.enterEmail,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.r),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: state.obscurePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => mapValidationErrorToMessage(
                            AuthValidators.password(value),
                            l10n,
                          ),
                          onChanged: (val) =>
                              cubit.handle(PasswordChanged(val)),
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            hintText: AppStrings.enterPassword,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.r),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.grey.shade400,
                                size: 20.w,
                              ),
                              onPressed: () =>
                                  cubit.handle(TogglePasswordVisibility()),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Remember Me & Forget Password
                        Row(
                          children: [
                            SizedBox(
                              height: 24.w,
                              width: 24.w,
                              child: Checkbox(
                                value: state.rememberMe,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                side: BorderSide(
                                  color: AppColors.grey.shade400,
                                  width: 1.5,
                                ),
                                onChanged: (val) => cubit.handle(
                                  RememberMeChanged(val ?? false),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              AppStrings.rememberMe,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.black),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                Routes.forgetPassword,
                              ),
                              child: Text(
                                AppStrings.forgetPassword,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.black,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // Continue Button (Grey when disabled, Primary when active)
                        CustomButton(
                          label: AppStrings.continueLabel,
                          isLoading: state.isLoading,
                          enabled: isFormFilled,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.handle(LoginSubmitted());
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
      ),
    );
  }
}
