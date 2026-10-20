import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/features/order_history/presentation/constants/order_history_dimens.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'common/centered_scroll_view.dart';

class ErrorMessageView extends StatelessWidget {
  const ErrorMessageView({super.key, required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CenteredScrollView(
      child: Padding(
        padding: EdgeInsets.all(OrderHistoryDimens.paddingXxxl.w),
        child: Text(
          mapAppFailureToMessage(failure, l10n),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
