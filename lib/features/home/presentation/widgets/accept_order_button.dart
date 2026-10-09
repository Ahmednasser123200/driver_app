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
        return previous.acceptOrderId.contains(orderId) !=
            current.acceptOrderId.contains(orderId);
      },
      builder: (context, state) {
        final isLoading = state.acceptOrderId.contains(orderId);
        return SizedBox(
          width: 140,
          height: 46,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    cubit.doEvent(AcceptOrderEvent(orderId));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
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
