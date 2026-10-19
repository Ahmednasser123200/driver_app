import 'package:driver_app/config/routing/app_routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/widgets/active_order_button.dart';
import 'package:driver_app/features/home/presentation/widgets/available_orders_list.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeDriverView extends StatefulWidget {
  const HomeDriverView({super.key});

  @override
  State<HomeDriverView> createState() => _HomeDriverViewState();
}

class _HomeDriverViewState extends State<HomeDriverView> with RouteAware {
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && !identical(route, _route)) {
      _route = route;
      AppRoutes.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRoutes.routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// A route pushed on top of Home (the order details) has been popped back to
  /// us: the driver may have completed or updated the order there, so re-read
  /// which order — if any — is still active instead of keeping a stale top
  /// button. Id-only lookup; it neither reloads the list nor accepts anything.
  @override
  void didPopNext() {
    if (!mounted) return;
    context.read<HomeCubit>().doEvent(RefreshActiveOrderEvent());
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
      body: Column(
        children: [
          const ActiveOrderButton(),
          const Expanded(child: AvailableOrdersList()),
        ],
      ),
    );
  }
}
