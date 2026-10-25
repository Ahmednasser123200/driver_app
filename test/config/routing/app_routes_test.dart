import 'package:driver_app/config/routing/app_routes.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/order_details/presentation/view/delivery_success_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_harness.dart';

void main() {
  testWidgets('resolves the delivery success route to the success screen', (
    tester,
  ) async {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(name: Routes.deliverySuccess),
    );

    expect(route, isA<MaterialPageRoute<dynamic>>());

    await tester.pumpWidget(
      wrapWidget(
        Builder(
          builder: (context) =>
              (route as MaterialPageRoute<dynamic>).builder(context),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DeliverySuccessView), findsOneWidget);
  });

  test('registers the pickup-location route', () {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(name: Routes.pickupLocation),
    );

    expect(route, isA<MaterialPageRoute<dynamic>>());
    expect(route.settings.name, Routes.pickupLocation);
  });

  test('starts from only the configured initial route', () {
    final routes = AppRoutes.onGenerateInitialRoutes(Routes.pickupLocation);

    expect(routes, hasLength(1));
    expect(routes.single.settings.name, Routes.pickupLocation);
  });
}
