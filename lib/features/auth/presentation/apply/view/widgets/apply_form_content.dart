import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/custom_text_form_field.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_intent.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';

import 'apply_country_field.dart';
import 'apply_file_upload_field.dart';
import 'apply_gender_selector.dart';
import 'apply_header.dart';
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
  final VoidCallback onContinuePressed;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyCubit>();
    final gap = SizedBox(height: 16.h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ApplyHeader(),
        gap,
        BlocBuilder<ApplyCubit, ApplyState>(
          buildWhen: (prev, curr) =>
              prev.countriesStatus != curr.countriesStatus ||
              prev.selectedCountry != curr.selectedCountry,
          builder: (context, state) {
            return ApplyCountryField(
              countries: state.countriesStatus.data ?? [],
              selectedCountry: state.selectedCountry,
              onCountrySelected: (country) =>
                  cubit.processIntent(SelectCountryIntent(country)),
            );
          },
        ),
        gap,
        CustomTextFormField(
          label: AppStrings.firstLegalName,
          hint: AppStrings.enterFirstLegalName,
          controller: firstNameController,
          validator: AuthValidators.firstName,
          textInputAction: TextInputAction.next,
          onChanged: (val) => cubit.processIntent(ChangeFirstNameIntent(val)),
        ),
        gap,
        CustomTextFormField(
          label: AppStrings.secondLegalName,
          hint: AppStrings.enterSecondLegalName,
          controller: secondNameController,
          validator: AuthValidators.lastName,
          textInputAction: TextInputAction.next,
          onChanged: (val) => cubit.processIntent(ChangeSecondNameIntent(val)),
        ),
        gap,
        BlocBuilder<ApplyCubit, ApplyState>(
          buildWhen: (prev, curr) =>
              prev.vehicleTypesStatus != curr.vehicleTypesStatus ||
              prev.selectedVehicleType != curr.selectedVehicleType,
          builder: (context, state) {
            return ApplyVehicleTypeField(
              vehicleTypes: state.vehicleTypesStatus.data ?? [],
              selectedVehicleType: state.selectedVehicleType,
              onVehicleTypeSelected: (type) =>
                  cubit.processIntent(SelectVehicleTypeIntent(type)),
            );
          },
        ),
        gap,
        CustomTextFormField(
          label: AppStrings.vehicleNumber,
          hint: AppStrings.enterVehicleNumber,
          controller: vehicleNumberController,
          validator: AuthValidators.addressFields,
          textInputAction: TextInputAction.next,
          onChanged: (val) =>
              cubit.processIntent(ChangeVehicleNumberIntent(val)),
        ),
        gap,
        BlocSelector<ApplyCubit, ApplyState, String?>(
          selector: (state) => state.vehicleLicencePath,
          builder: (context, vehicleLicencePath) {
            return ApplyFileUploadField(
              label: AppStrings.vehicleLicense,
              hint: AppStrings.uploadLicensePhoto,
              filePath: vehicleLicencePath,
              onTap: () => cubit.processIntent(const PickLicenseImageIntent()),
            );
          },
        ),
        gap,
        CustomTextFormField(
          label: AppStrings.email,
          hint: AppStrings.enterEmail,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: AuthValidators.email,
          textInputAction: TextInputAction.next,
          onChanged: (val) => cubit.processIntent(ChangeEmailIntent(val)),
        ),
        gap,
        CustomTextFormField(
          label: AppStrings.phoneNumber,
          hint: AppStrings.enterPhoneNumber,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          validator: AuthValidators.phone,
          textInputAction: TextInputAction.next,
          onChanged: (val) => cubit.processIntent(ChangePhoneIntent(val)),
        ),
        gap,
        CustomTextFormField(
          label: AppStrings.idNumber,
          hint: AppStrings.enterNationalIdNumber,
          controller: nationalIdController,
          keyboardType: TextInputType.number,
          validator: AuthValidators.addressFields,
          textInputAction: TextInputAction.next,
          onChanged: (val) => cubit.processIntent(ChangeNationalIdIntent(val)),
        ),
        gap,
        BlocSelector<ApplyCubit, ApplyState, String?>(
          selector: (state) => state.idImagePath,
          builder: (context, idImagePath) {
            return ApplyFileUploadField(
              label: AppStrings.idImage,
              hint: AppStrings.uploadIdImage,
              filePath: idImagePath,
              onTap: () => cubit.processIntent(const PickIdImageIntent()),
            );
          },
        ),
        gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                label: AppStrings.password,
                hint: AppStrings.enterPassword,
                controller: passwordController,
                obscureText: true,
                validator: AuthValidators.strongPassword,
                textInputAction: TextInputAction.next,
                onChanged: (val) =>
                    cubit.processIntent(ChangePasswordIntent(val)),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomTextFormField(
                label: AppStrings.confirmPassword,
                hint: AppStrings.confirmPassword,
                controller: confirmPasswordController,
                obscureText: true,
                validator: (value) => AuthValidators.confirmPassword(
                  value,
                  passwordController.text,
                ),
                onChanged: (val) =>
                    cubit.processIntent(ChangeConfirmPasswordIntent(val)),
              ),
            ),
          ],
        ),
        gap,
        BlocSelector<ApplyCubit, ApplyState, String?>(
          selector: (state) => state.gender,
          builder: (context, gender) {
            return ApplyGenderSelector(
              selectedGender: gender,
              onGenderChanged: (val) =>
                  cubit.processIntent(ChangeGenderIntent(val)),
            );
          },
        ),
        SizedBox(height: 32.h),
        BlocSelector<ApplyCubit, ApplyState, bool>(
          selector: (state) => state.applyStatus.isLoading,
          builder: (context, isLoading) {
            return CustomButton(
              label: AppStrings.continueLabel,
              width: double.infinity,
              isLoading: isLoading,
              onPressed: onContinuePressed,
            );
          },
        ),
      ],
    );
  }
}
