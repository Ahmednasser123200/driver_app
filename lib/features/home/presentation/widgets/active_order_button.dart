import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

/// Shortcut to the delivery the driver is already running.
///
/// It is only shown once the active-order lookup has resolved to a real id, and
/// it only navigates to that order: accepting stays on the available-order
/// cards. `null` (loading / failed lookup) and `''` (confirmed absence) both
/// render nothing, so no placeholder or gap is left behind.
class ActiveOrderButton extends StatelessWidget {
  const ActiveOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.activeOrderId != current.activeOrderId,
      builder: (context, state) {
        final activeOrderId = state.activeOrderId;
        if (activeOrderId == null || activeOrderId.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(
            label: local.viewActiveOrder,
            onPressed: () => context.read<HomeCubit>().doEvent(
              OpenOrderDetailsEvent(activeOrderId),
            ),
          ),
        );
      },
    );
  }
}
