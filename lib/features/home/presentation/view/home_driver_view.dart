import 'dart:async';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/view/mixin_handle_ui_event.dart';
import 'package:driver_app/features/home/presentation/widgets/available_orders_list.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeDriverView extends StatefulWidget {
  const HomeDriverView({super.key});

  @override
  State<HomeDriverView> createState() => _HomeDriverViewState();
}

class _HomeDriverViewState extends State<HomeDriverView> with HandleEventUi  {
  late final HomeCubit _cubit;
  late final StreamSubscription<BaseUiEvent> _subscription;
  //   String _successText(AppLocalizations local, AppMessage message) {
  //   switch (message) {
  //     case AppMessage.orderAccepted:
  //       return local.accepted;
  //   }
  // }
  @override
  void initState() {
    super.initState();
    _cubit = context.read<HomeCubit>();
    _subscription = _cubit.uiEventStream.listen((event) {
      if (!mounted) return;
  //  final local = AppLocalizations.of(context)!;
      handleEvent(context, event);
      // switch (event) {
      //   case ShowSuccessMessage():
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(handleSuccessText(local, event.message)),
      //         backgroundColor: Colors.green,
      //       ),
      //     );
      //   case ShowFailureMessage():
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(mapAppFailureToMessage(event.failure, local)),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //   case NavigateTo():
      //     Navigator.pushNamed(
      //       context,
      //       event.routeName,
      //       arguments: event.arguments,
      //     );
      //   case PopRoute():
      //     Navigator.pop(context, event.result);
      // }
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: false,
        title: Text(
          local.appName,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const AvailableOrdersList(),
    );
  }
}
