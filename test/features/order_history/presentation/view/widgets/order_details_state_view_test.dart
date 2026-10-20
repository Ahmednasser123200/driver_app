import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_content.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_state_view.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('shows a spinner while loading without data', (tester) async {
    await pumpApp(
      tester,
      const OrderDetailsStateView(
        state: OrderDetailsState(
          orderDetails: BaseState(isLoading: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows localized error message when loading fails', (tester) async {
    await pumpApp(
      tester,
      const OrderDetailsStateView(
        state: OrderDetailsState(failure: NotFoundFailure()),
      ),
    );

    expect(find.text(AppLocalizationsEn().failureNotFound), findsOneWidget);
  });

  testWidgets('shows content when details are available', (tester) async {
    final details = createOrderHistoryDetailsEntity();

    await pumpApp(
      tester,
      OrderDetailsStateView(
        state: OrderDetailsState(
          orderDetails: BaseState(data: details),
        ),
      ),
    );

    expect(find.byType(OrderDetailsContent), findsOneWidget);
  });
}
