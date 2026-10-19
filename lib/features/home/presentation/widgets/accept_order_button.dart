import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AcceptOrderButton extends StatelessWidget {
  final AppLocalizations local;
  final String orderId;
  const AcceptOrderButton({
    super.key,
    required this.local,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        return previous.acceptOrderId != current.acceptOrderId;
      },
      builder: (context, state) {
        final hasRunningAccept = state.acceptOrderId.isNotEmpty;
        final isLoading = state.acceptOrderId == orderId;
        // Every card keeps the primary colour and stays tappable: the cubit
        // decides what a tap means (open the driver's own order, explain that a
        // delivery is already running, or accept this one).
        return SizedBox(
          width: 140,
          height: 46,
          child: ElevatedButton(
            onPressed: hasRunningAccept
                ? null
                : () => cubit.doEvent(AcceptOrderEvent(orderId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Text(local.accept),
          ),
        );
      },
    );
  }
}
