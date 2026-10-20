import 'package:driver_app/features/order_history/presentation/view/widgets/common/centered_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('CenteredScrollView renders child in scroll view', (tester) async {
    await pumpApp(tester, const CenteredScrollView(child: Text('Centered Content')));
    expect(find.text('Centered Content'), findsOneWidget);
  });
}
