import 'dart:io';

import 'package:flutter/material.dart';

import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplyFileUploadField extends StatelessWidget {
  final String label;
  final String hint;
  final ValueNotifier<File?> fileNotifier;
  final VoidCallback onTap;

  const ApplyFileUploadField({
    super.key,
    required this.label,
    required this.hint,
    required this.fileNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<File?>(
      valueListenable: fileNotifier,
      builder: (context, file, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: InputDecorator(
            isEmpty: false,
            decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: const Icon(Icons.file_upload_outlined),
            ),
            child: Text(
              file == null ? hint : file.path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: file == null
                  ? theme.inputDecorationTheme.hintStyle
                  : theme.textTheme.bodyMedium?.copyWith(color: AppColors.black),
            ),
          ),
        );
      },
    );
  }
}