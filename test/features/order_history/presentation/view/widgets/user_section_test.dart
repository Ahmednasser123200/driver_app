import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/user_section.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('renders section title and user address card', (tester) async {
    final user = createOrderUserEntity(
      name: 'Recipient',
      address: 'Recipient Street',
      imageUrl: null,
    );

    await pumpApp(tester, UserSection(user: user));

    expect(find.text(AppStrings.userAddress), findsOneWidget);
    expect(find.text('Recipient'), findsOneWidget);
    expect(find.text('Recipient Street'), findsOneWidget);
  });
}
