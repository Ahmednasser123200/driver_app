import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/pickup_section.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('renders section title and store address card', (tester) async {
    final store = createOrderStoreEntity(
      name: 'Pickup Store',
      address: 'Pickup Street',
      imageUrl: null,
    );

    await pumpApp(tester, PickupSection(store: store));

    expect(find.text(AppStrings.pickupAddress), findsOneWidget);
    expect(find.text('Pickup Store'), findsOneWidget);
    expect(find.text('Pickup Street'), findsOneWidget);
  });
}
