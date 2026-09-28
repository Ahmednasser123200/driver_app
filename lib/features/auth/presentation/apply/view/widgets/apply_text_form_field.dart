import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:driver_app/config/localization/validation_error_message_mapper.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

class ApplyTextFormField extends StatefulWidget {
  const ApplyTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.isPassword = false,
    this.suffixIcon,
    this.onChanged,
    this.forceShowErrors = false,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final ValidationError? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool forceShowErrors;

  @override
  State<ApplyTextFormField> createState() => _ApplyTextFormFieldState();
}

class _ApplyTextFormFieldState extends State<ApplyTextFormField> {
  late final FocusNode _focusNode;
  bool _hasInteracted = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.isPassword;
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_hasInteracted) {
      setState(() => _hasInteracted = true);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shouldValidate = _hasInteracted || widget.forceShowErrors;

    return TextFormField(
      focusNode: _focusNode,
      autovalidateMode: shouldValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      controller: widget.controller,
      validator: widget.validator == null
          ? null
          : (value) =>
                mapValidationErrorToMessage(widget.validator!(value), l10n),
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      onChanged: (val) {
        if (!_hasInteracted) setState(() => _hasInteracted = true);
        widget.onChanged?.call(val);
      },
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
      ),
    );
  }
}
