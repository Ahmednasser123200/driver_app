import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_intent.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

import '../manager/apply_ui_event.dart';
import 'widgets/apply_form_content.dart';

class ApplyView extends StatelessWidget {
  const ApplyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApplyCubit>(
      create: (_) => getIt<ApplyCubit>(),
      child: const _ApplyViewBody(),
    );
  }
}

class _ApplyViewBody extends StatefulWidget {
  const _ApplyViewBody();

  @override
  State<_ApplyViewBody> createState() => _ApplyViewBodyState();
}

class _ApplyViewBodyState extends State<_ApplyViewBody> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _vehicleNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinuePressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ApplyCubit>().processIntent(const SubmitApplicationIntent());
  }

  void _onCustomEvent(BuildContext context, BaseUiEvent event) {
    final l10n = AppLocalizations.of(context)!;
    switch (event) {
      case ApplySuccessEvent():
        Navigator.pushReplacementNamed(context, Routes.successApply);
      case ApplyFailureEvent(:final failure):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(mapAppFailureToMessage(failure, l10n)),
              backgroundColor: AppColors.error,
            ),
          );
      case ApplyGenderMissingEvent():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(AppStrings.pleaseSelectGender),
              backgroundColor: AppColors.error,
            ),
          );
      case ApplyLicenseMissingEvent():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(AppStrings.pleaseUploadVehicleLicense),
              backgroundColor: AppColors.error,
            ),
          );
      case ApplyIdImageMissingEvent():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(AppStrings.pleaseUploadIdImage),
              backgroundColor: AppColors.error,
            ),
          );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseUiEventListener<ApplyCubit, ApplyState, ApplyUiEvent>(
      onCustomEvent: (context, event) => _onCustomEvent(context, event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(AppStrings.apply),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: ApplyFormContent(
              firstNameController: _firstNameController,
              secondNameController: _secondNameController,
              vehicleNumberController: _vehicleNumberController,
              emailController: _emailController,
              phoneController: _phoneController,
              nationalIdController: _nationalIdController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              onContinuePressed: () => _onContinuePressed(context),
            ),
          ),
        ),
      ),
    );
  }
}