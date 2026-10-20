import 'package:driver_app/features/order_history/presentation/view/widgets/common/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('InfoCard renders child widget', (tester) async {
    await pumpApp(tester, const InfoCard(child: Text('Card Content')));
    expect(find.text('Card Content'), findsOneWidget);
  });
}
