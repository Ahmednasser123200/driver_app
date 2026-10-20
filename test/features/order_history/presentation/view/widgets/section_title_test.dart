import 'package:driver_app/features/order_history/presentation/view/widgets/common/section_title.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('SectionTitle renders title text', (tester) async {
    await pumpApp(tester, const SectionTitle(text: 'Test Title'));
    expect(find.text('Test Title'), findsOneWidget);
  });
}
