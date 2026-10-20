import 'package:driver_app/features/order_history/presentation/view/widgets/summary_row.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('SummaryRow displays label and value', (tester) async {
    await pumpApp(tester, const SummaryRow(label: 'Total', value: 'EGP 100'));
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('EGP 100'), findsOneWidget);
  });
}
