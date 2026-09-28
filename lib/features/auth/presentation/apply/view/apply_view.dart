import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_picker/image_picker.dart';

import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/core/shared/widgets/base_ui_event_listener.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_event.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

import '../../../../../config/di/di.dart';
import 'widgets/apply_country_field.dart';
import 'widgets/apply_file_upload_field.dart';
import 'widgets/apply_gender_selector.dart';
import 'widgets/apply_header.dart';
import 'widgets/apply_text_form_field.dart';
import 'widgets/apply_vehicle_type_field.dart';

class ApplyView extends StatelessWidget {
  const ApplyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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

  final _countryNotifier = ValueNotifier<Country>(Country.parse('EG'));
  final _vehicleTypeNotifier = ValueNotifier<VehicleType>(VehicleType.car);
  final _licenseFileNotifier = ValueNotifier<File?>(null);
  final _idImageNotifier = ValueNotifier<File?>(null);
  final _isFemaleNotifier = ValueNotifier<bool?>(null);

  final ImagePicker _picker = ImagePicker();
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ApplyCubit>();

    cubit.onCountryChanged(_countryNotifier.value.name);
    cubit.onVehicleTypeChanged(_vehicleTypeNotifier.value);

    _countryNotifier.addListener(
      () => cubit.onCountryChanged(_countryNotifier.value.name),
    );
    _vehicleTypeNotifier.addListener(
      () => cubit.onVehicleTypeChanged(_vehicleTypeNotifier.value),
    );
    _licenseFileNotifier.addListener(() {
      final file = _licenseFileNotifier.value;
      if (file != null) cubit.onLicenseFilePicked(file);
    });
    _idImageNotifier.addListener(() {
      final file = _idImageNotifier.value;
      if (file != null) cubit.onIdImagePicked(file);
    });
    _isFemaleNotifier.addListener(() {
      final isFemale = _isFemaleNotifier.value;
      if (isFemale != null) {
        cubit.onGenderChanged(isFemale ? 'Female' : 'Male');
      }
    });
  }

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
    _countryNotifier.dispose();
    _vehicleTypeNotifier.dispose();
    _licenseFileNotifier.dispose();
    _idImageNotifier.dispose();
    _isFemaleNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
    ValueNotifier<File?> notifier,
    void Function(File) onPicked,
  ) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      notifier.value = file;
      onPicked(file);
    }
  }

  void _onContinuePressed(BuildContext context) {
    setState(() => _isSubmitted = true);

    if (!_formKey.currentState!.validate()) return;

    final isFemale = _isFemaleNotifier.value;
    if (isFemale != null) {
      context.read<ApplyCubit>().onGenderChanged(isFemale ? 'Female' : 'Male');
    }

    context.read<ApplyCubit>().submit();
  }

  void _onUiEvent(BuildContext context, ApplyEvent event) {
    final l10n = AppLocalizations.of(context)!;
    switch (event) {
      case ApplySuccessEvent():
        Navigator.pushReplacementNamed(context, Routes.successApply);
      case ApplyFailureEvent(:final failure):
        _showSnackBar(
          context,
          mapAppFailureToMessage(failure, l10n),
        );
      case ApplyGenderMissingEvent():
        _showSnackBar(context, AppStrings.pleaseSelectGender);
      case ApplyLicenseMissingEvent():
        _showSnackBar(context, AppStrings.pleaseUploadVehicleLicense);
      case ApplyIdImageMissingEvent():
        _showSnackBar(context, AppStrings.pleaseUploadIdImage);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
  }

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 16.h);

    return BaseUiEventListener<BaseState<ApplyState>, ApplyEvent>(
      cubit: context.read<ApplyCubit>(),
      onEvent: _onUiEvent,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ApplyHeader(),
                gap,
                ApplyCountryField(countryNotifier: _countryNotifier),
                gap,
                ApplyTextFormField(
                  label: AppStrings.firstLegalName,
                  hintText: AppStrings.enterFirstLegalName,
                  controller: _firstNameController,
                  validator: AuthValidators.firstName,
                  textInputAction: TextInputAction.next,
                  onChanged: context.read<ApplyCubit>().onFirstNameChanged,
                  forceShowErrors: _isSubmitted,
                ),
                gap,
                ApplyTextFormField(
                  label: AppStrings.secondLegalName,
                  hintText: AppStrings.enterSecondLegalName,
                  controller: _secondNameController,
                  validator: AuthValidators.lastName,
                  textInputAction: TextInputAction.next,
                  onChanged: context.read<ApplyCubit>().onSecondNameChanged,
                  forceShowErrors: _isSubmitted,
                ),
                gap,
                ApplyVehicleTypeField(vehicleTypeNotifier: _vehicleTypeNotifier),
                gap,
                ApplyTextFormField(
                  label: AppStrings.vehicleNumber,
                  hintText: AppStrings.enterVehicleNumber,
                  controller: _vehicleNumberController,
                  validator: AuthValidators.addressFields,
                  textInputAction: TextInputAction.next,
                  onChanged: context.read<ApplyCubit>().onVehicleNumberChanged,
                  forceShowErrors: _isSubmitted,
                ),
                gap,
                ApplyFileUploadField(
                  label: AppStrings.vehicleLicense,
                  hint: AppStrings.uploadLicensePhoto,
                  fileNotifier: _licenseFileNotifier,
                  onTap: () => _pickImage(
                    _licenseFileNotifier,
                    context.read<ApplyCubit>().onLicenseFilePicked,
                  ),
                ),
                gap,
                ApplyTextFormField(
                  label: AppStrings.email,
                  hintText: AppStrings.enterEmail,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  textInputAction: TextInputAction.next,
                  onChanged: context.read<ApplyCubit>().onEmailChanged,
                  forceShowErrors: _isSubmitted,
                ),
                gap,
                ApplyTextFormField(
                  label: AppStrings.phoneNumber,
                  hintText: AppStrings.enterPhoneNumber,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: AuthValidators.phone,
                  textInputAction: TextInputAction.next,
                  onChanged: context.read<ApplyCubit>().onPhoneChanged,
                  forceShowErrors: _isSubmitted,
                ),
                gap,
                ApplyTextFormField(
                  label: AppStrings.idNumber,
                  hintText: AppStrings.enterNationalIdNumber,
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                  validator: AuthValidators.addressFields,
                  textInputAction: TextInputAction.next,
                  onChanged: context.read<ApplyCubit>().onNationalIdChanged,
                  forceShowErrors: _isSubmitted,
                ),
                gap,
                ApplyFileUploadField(
                  label: AppStrings.idImage,
                  hint: AppStrings.uploadIdImage,
                  fileNotifier: _idImageNotifier,
                  onTap: () => _pickImage(
                    _idImageNotifier,
                    context.read<ApplyCubit>().onIdImagePicked,
                  ),
                ),
                gap,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ApplyTextFormField(
                        label: AppStrings.password,
                        hintText: AppStrings.enterPassword,
                        controller: _passwordController,
                        isPassword: true,
                        validator: AuthValidators.strongPassword,
                        textInputAction: TextInputAction.next,
                        onChanged: context.read<ApplyCubit>().onPasswordChanged,
                        forceShowErrors: _isSubmitted,
                      ),
                    ),
                    SizedBox(width: 17.w),
                    Expanded(
                      child: ApplyTextFormField(
                        label: AppStrings.confirmPassword,
                        hintText: AppStrings.confirmPassword,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (value) => AuthValidators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        onChanged:
                            context.read<ApplyCubit>().onConfirmPasswordChanged,
                        forceShowErrors: _isSubmitted,
                      ),
                    ),
                  ],
                ),
                gap,
                ApplyGenderSelector(isFemaleNotifier: _isFemaleNotifier),
                SizedBox(height: 48.h),
                BlocBuilder<ApplyCubit, BaseState<ApplyState>>(
                  buildWhen: (previous, current) =>
                      previous.isLoading != current.isLoading,
                  builder: (context, state) => CustomButton(
                    label: AppStrings.continueLabel,
                    width: double.infinity,
                    isLoading: state.isLoading,
                    onPressed: () => _onContinuePressed(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
