import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/custom_text_form_field.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_intent.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_ui_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => getIt<LoginCubit>(),
      child: const _LoginViewContent(),
    );
  }
}

class _LoginViewContent extends StatefulWidget {
  const _LoginViewContent();

  @override
  State<_LoginViewContent> createState() => _LoginViewContentState();
}

class _LoginViewContentState extends State<_LoginViewContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LoginCubit>().handle(LoadRememberedEmail());
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          onCustomEvent: (context, event) {
            if (event is EmailPreFilledEvent) {
              _emailController.text = event.email;
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 24.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email Field
                  CustomTextFormField(
                    label: AppStrings.email,
                    hint: AppStrings.enterEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.email,
                    onChanged: (val) =>
                        context.read<LoginCubit>().handle(EmailChanged(val)),
                  ),
                  SizedBox(height: 20.h),

                  // Password Field
                  BlocSelector<LoginCubit, LoginState, bool>(
                    selector: (state) => state.obscurePassword,
                    builder: (context, obscurePassword) {
                      return CustomTextFormField(
                        label: AppStrings.password,
                        hint: AppStrings.enterPassword,
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        validator: AuthValidators.password,
                        onChanged: (val) => context
                            .read<LoginCubit>()
                            .handle(PasswordChanged(val)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grey.shade400,
                            size: 20.w,
                          ),
                          onPressed: () => context
                              .read<LoginCubit>()
                              .handle(TogglePasswordVisibility()),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Remember Me & Forget Password
                  Row(
                    children: [
                      SizedBox(
                        height: 24.w,
                        width: 24.w,
                        child: BlocSelector<LoginCubit, LoginState, bool>(
                          selector: (state) => state.rememberMe,
                          builder: (context, rememberMe) {
                            return Checkbox(
                              value: rememberMe,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              side: BorderSide(
                                color: AppColors.grey.shade400,
                                width: 1.5,
                              ),
                              onChanged: (val) => context
                                  .read<LoginCubit>()
                                  .handle(RememberMeChanged(val ?? false)),
                            );
                          },
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

                  // Continue Button
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      return CustomButton(
                        label: AppStrings.continueLabel,
                        isLoading: state.isLoading,
                        enabled: state.isFormFilled,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<LoginCubit>()
                                .handle(LoginSubmitted());
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}