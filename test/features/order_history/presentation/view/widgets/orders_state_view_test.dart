import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_content.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_state_view.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows a spinner while loading without data', (tester) async {
    await pumpApp(
      tester,
      const OrdersStateView(
        state: OrdersState(ordersListState: BaseState(isLoading: true)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows localized error message when loading fails', (tester) async {
    await pumpApp(
      tester,
      const OrdersStateView(
        state: OrdersState(
          ordersListState: BaseState(isLoading: false),
          failure: TimeoutFailure(),
        ),
      ),
    );

    expect(
      find.text(AppLocalizationsEn().failureTimeout),
      findsOneWidget,
    );
  });

  testWidgets('shows content when data is available', (tester) async {
    await pumpApp(
      tester,
      const OrdersStateView(
        state: OrdersState(
          ordersListState: BaseState(data: OrdersDataState()),
        ),
      ),
    );

    expect(find.byType(OrdersContent), findsOneWidget);
  });
}
