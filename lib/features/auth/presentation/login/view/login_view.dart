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
    return BlocProvider(
      create: (context) => getIt<LoginCubit>()..handle(LoadSavedEmail()),
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.login)),
        body: SafeArea(
          child: BaseUiEventListener<LoginCubit, LoginState, BaseUiEvent>(
            child: BlocConsumer<LoginCubit, LoginState>(
              listenWhen: (prev, curr) => prev.email != curr.email && _emailController.text.isEmpty,
              listener: (context, state) {
                _emailController.text = state.email;
              },
              builder: (context, state) {
                final cubit = context.read<LoginCubit>();

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.welcome,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppStrings.enterEmail,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.grey.shade500),
                        ),
                        SizedBox(height: 32.h),

                        // Email Field
                        CustomTextFormField(
                          controller: _emailController,
                          label: AppStrings.email,
                          hint: AppStrings.enterEmail,
                          keyboardType: TextInputType.emailAddress,
                          validator: AuthValidators.email,
                          onChanged: (val) => cubit.handle(EmailChanged(val)),
                        ),
                        SizedBox(height: 16.h),

                        // Password Field
                        CustomTextFormField(
                          controller: _passwordController,
                          label: AppStrings.password,
                          hint: AppStrings.enterPassword,
                          obscureText: state.obscurePassword,
                          validator: AuthValidators.password,
                          onChanged: (val) =>
                              cubit.handle(PasswordChanged(val)),
                        ),
                        SizedBox(height: 12.h),

                        // Remember Me & Forget Password
                        Row(
                          children: [
                            Checkbox(
                              value: state.rememberMe,
                              activeColor: AppColors.primary,
                              onChanged: (val) =>
                                  cubit.handle(RememberMeChanged(val ?? false)),
                            ),
                            Text(
                              AppStrings.rememberMe,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                Routes.forgetPassword,
                              ),
                              child: const Text(AppStrings.forgetPassword),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Login Button
                        CustomButton(
                          label: AppStrings.login,
                          isLoading: state.isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.handle(LoginSubmitted());
                            }
                          },
                        ),
                        SizedBox(height: 24.h),

                        // Join Team / Apply Now Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.deliveryManJoinTeam,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, Routes.apply),
                              child: const Text(
                                AppStrings.applyNow,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
