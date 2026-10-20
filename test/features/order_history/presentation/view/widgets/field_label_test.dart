import 'package:driver_app/features/order_history/presentation/view/widgets/common/field_label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('FieldLabel renders label text', (tester) async {
    await pumpApp(tester, const FieldLabel(text: 'Label Text'));
    expect(find.text('Label Text'), findsOneWidget);
  });
}
