import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_history_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  appBar: OrderHistoryAppBar(title: AppStrings.orderDetails),
                ),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('hides the back button when showBack is false', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        appBar: OrderHistoryAppBar(
          title: AppStrings.myOrders,
          showBack: false,
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    expect(find.text(AppStrings.myOrders), findsOneWidget);
  });

  testWidgets('tapping the back button pops the route', (tester) async {
    await pumpApp(tester, const _Launcher());

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    expect(find.text(AppStrings.orderDetails), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });
}
