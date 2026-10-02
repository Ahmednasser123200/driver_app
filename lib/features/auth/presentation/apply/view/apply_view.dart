import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_picker/image_picker.dart';

import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_cubit.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_event.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

import '../../../../../config/di/di.dart';
import 'widgets/apply_form_content.dart';

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

  StreamSubscription<ApplyEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ApplyCubit>();

    _eventSubscription = cubit.applyEventStream.listen((event) {
      if (!mounted) return;
      _onUiEvent(context, event);
    });

    cubit.onCountryChanged('+${_countryNotifier.value.phoneCode}');
    cubit.onVehicleTypeChanged(_vehicleTypeNotifier.value);

    _countryNotifier.addListener(
          () => cubit.onCountryChanged('+${_countryNotifier.value.phoneCode}'),
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
    _eventSubscription?.cancel();
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
        _showSnackBar(context, mapAppFailureToMessage(failure, l10n));
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
    final cubit = context.read<ApplyCubit>();

    return Scaffold(
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
            countryNotifier: _countryNotifier,
            vehicleTypeNotifier: _vehicleTypeNotifier,
            licenseFileNotifier: _licenseFileNotifier,
            idImageNotifier: _idImageNotifier,
            isFemaleNotifier: _isFemaleNotifier,
            isSubmitted: _isSubmitted,
            onFirstNameChanged: cubit.onFirstNameChanged,
            onSecondNameChanged: cubit.onSecondNameChanged,
            onVehicleNumberChanged: cubit.onVehicleNumberChanged,
            onEmailChanged: cubit.onEmailChanged,
            onPhoneChanged: cubit.onPhoneChanged,
            onNationalIdChanged: cubit.onNationalIdChanged,
            onPasswordChanged: cubit.onPasswordChanged,
            onConfirmPasswordChanged: cubit.onConfirmPasswordChanged,
            onPickLicense: () =>
                _pickImage(_licenseFileNotifier, cubit.onLicenseFilePicked),
            onPickIdImage: () =>
                _pickImage(_idImageNotifier, cubit.onIdImagePicked),
            onContinuePressed: () => _onContinuePressed(context),
          ),
        ),
      ),
    );
  }
}