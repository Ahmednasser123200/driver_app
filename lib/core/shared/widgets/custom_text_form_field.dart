import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../config/localization/validation_error_message_mapper.dart';
import '../../../config/utils/auth_validators.dart';
import '../../themes/app_colors/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
  });

  final String label;
  final String? hint;
  final String? value;
  final ValidationError? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final FocusNode? focusNode;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _controller;
  final ValueNotifier<bool> _obscureText = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _obscureText.value = widget.obscureText;
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != (widget.value ?? '')) {
      _controller.text = widget.value ?? '';
    }
    _obscureText.value = widget.obscureText;
  }

  @override
  void dispose() {
    _controller.dispose();
    _obscureText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(color: AppColors.black),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _controller,
          validator: widget.validator == null
              ? null
              : (value) =>
                    mapValidationErrorToMessage(widget.validator!(value), l10n),
          obscureText: _obscureText.value,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          focusNode: widget.focusNode,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.black),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText && widget.suffixIcon == null
                ? ValueListenableBuilder<bool>(
                    valueListenable: _obscureText,
                    builder: (context, obscure, _) {
                      return IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey.shade400,
                          size: 20.w,
                        ),
                        onPressed: () {
                          _obscureText.value = !obscure;
                        },
                      );
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
