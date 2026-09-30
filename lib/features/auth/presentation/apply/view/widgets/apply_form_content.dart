import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';

import 'apply_country_field.dart';
import 'apply_file_upload_field.dart';
import 'apply_gender_selector.dart';
import 'apply_header.dart';
import 'apply_text_form_field.dart';
import 'apply_vehicle_type_field.dart';

class ApplyFormContent extends StatelessWidget {
  const ApplyFormContent({
    super.key,
    required this.firstNameController,
    required this.secondNameController,
    required this.vehicleNumberController,
    required this.emailController,
    required this.phoneController,
    required this.nationalIdController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.countryNotifier,
    required this.vehicleTypeNotifier,
    required this.licenseFileNotifier,
    required this.idImageNotifier,
    required this.isFemaleNotifier,
    required this.isSubmitted,
    required this.onFirstNameChanged,
    required this.onSecondNameChanged,
    required this.onVehicleNumberChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onNationalIdChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onPickLicense,
    required this.onPickIdImage,
    required this.onContinuePressed,
  });

  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController vehicleNumberController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nationalIdController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final ValueNotifier<Country> countryNotifier;
  final ValueNotifier<VehicleType> vehicleTypeNotifier;
  final ValueNotifier<File?> licenseFileNotifier;
  final ValueNotifier<File?> idImageNotifier;
  final ValueNotifier<bool?> isFemaleNotifier;

  final bool isSubmitted;

  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onSecondNameChanged;
  final ValueChanged<String> onVehicleNumberChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onNationalIdChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final VoidCallback onPickLicense;
  final VoidCallback onPickIdImage;
  final VoidCallback onContinuePressed;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 16.h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ApplyHeader(),
        gap,
        ApplyCountryField(countryNotifier: countryNotifier),
        gap,
        ApplyTextFormField(
          label: AppStrings.firstLegalName,
          hintText: AppStrings.enterFirstLegalName,
          controller: firstNameController,
          validator: AuthValidators.firstName,
          textInputAction: TextInputAction.next,
          onChanged: onFirstNameChanged,
          forceShowErrors: isSubmitted,
        ),
        gap,
        ApplyTextFormField(
          label: AppStrings.secondLegalName,
          hintText: AppStrings.enterSecondLegalName,
          controller: secondNameController,
          validator: AuthValidators.lastName,
          textInputAction: TextInputAction.next,
          onChanged: onSecondNameChanged,
          forceShowErrors: isSubmitted,
        ),
        gap,
        ApplyVehicleTypeField(vehicleTypeNotifier: vehicleTypeNotifier),
        gap,
        ApplyTextFormField(
          label: AppStrings.vehicleNumber,
          hintText: AppStrings.enterVehicleNumber,
          controller: vehicleNumberController,
          validator: AuthValidators.addressFields,
          textInputAction: TextInputAction.next,
          onChanged: onVehicleNumberChanged,
          forceShowErrors: isSubmitted,
        ),
        gap,
        ApplyFileUploadField(
          label: AppStrings.vehicleLicense,
          hint: AppStrings.uploadLicensePhoto,
          fileNotifier: licenseFileNotifier,
          onTap: onPickLicense,
        ),
        gap,
        ApplyTextFormField(
          label: AppStrings.email,
          hintText: AppStrings.enterEmail,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: AuthValidators.email,
          textInputAction: TextInputAction.next,
          onChanged: onEmailChanged,
          forceShowErrors: isSubmitted,
        ),
        gap,
        ApplyTextFormField(
          label: AppStrings.phoneNumber,
          hintText: AppStrings.enterPhoneNumber,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          validator: AuthValidators.phone,
          textInputAction: TextInputAction.next,
          onChanged: onPhoneChanged,
          forceShowErrors: isSubmitted,
        ),
        gap,
        ApplyTextFormField(
          label: AppStrings.idNumber,
          hintText: AppStrings.enterNationalIdNumber,
          controller: nationalIdController,
          keyboardType: TextInputType.number,
          validator: AuthValidators.addressFields,
          textInputAction: TextInputAction.next,
          onChanged: onNationalIdChanged,
          forceShowErrors: isSubmitted,
        ),
        gap,
        ApplyFileUploadField(
          label: AppStrings.idImage,
          hint: AppStrings.uploadIdImage,
          fileNotifier: idImageNotifier,
          onTap: onPickIdImage,
        ),
        gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ApplyTextFormField(
                label: AppStrings.password,
                hintText: AppStrings.enterPassword,
                controller: passwordController,
                isPassword: true,
                validator: AuthValidators.strongPassword,
                textInputAction: TextInputAction.next,
                onChanged: onPasswordChanged,
                forceShowErrors: isSubmitted,
              ),
            ),
            SizedBox(width: 17.w),
            Expanded(
              child: ApplyTextFormField(
                label: AppStrings.confirmPassword,
                hintText: AppStrings.confirmPassword,
                controller: confirmPasswordController,
                isPassword: true,
                validator: (value) => AuthValidators.confirmPassword(
                  value,
                  passwordController.text,
                ),
                onChanged: onConfirmPasswordChanged,
                forceShowErrors: isSubmitted,
              ),
            ),
          ],
        ),
        gap,
        ApplyGenderSelector(isFemaleNotifier: isFemaleNotifier),
        SizedBox(height: 48.h),
        BlocBuilder<ApplyCubit, BaseState<ApplyState>>(
          buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
          builder: (context, state) => CustomButton(
            label: AppStrings.continueLabel,
            width: double.infinity,
            isLoading: state.isLoading,
            onPressed: onContinuePressed,
          ),
        ),
      ],
    );
  }
}