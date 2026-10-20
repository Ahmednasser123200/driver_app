import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_card.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  List<OrderHistoryEntity> buildOrders(int count) {
    return List.generate(
      count,
      (i) => createOrderHistoryEntity(
        orderId: '$i',
        store: createOrderStoreEntity(imageUrl: null),
        user: createOrderUserEntity(imageUrl: null),
      ),
    );
  }

  testWidgets('renders cards and loading indicator when isLoadingMore', (tester) async {
    await pumpApp(
      tester,
      OrdersList(
        orders: buildOrders(1),
        isLoadingMore: true,
        loadMoreFailed: false,
        onLoadMore: () {},
      ),
    );

    expect(find.byType(OrderCard), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calls onLoadMore when scrolled near the end', (tester) async {
    var loadMoreCalled = false;

    await pumpApp(
      tester,
      OrdersList(
        orders: buildOrders(20),
        isLoadingMore: false,
        loadMoreFailed: false,
        onLoadMore: () => loadMoreCalled = true,
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -10000));
    await tester.pump();

    expect(loadMoreCalled, isTrue);
  });

  testWidgets('when loadMoreFailed is true it fires once on scroll end at the end', (tester) async {
    var loadMoreCallCount = 0;

    await pumpApp(
      tester,
      OrdersList(
        orders: buildOrders(20),
        isLoadingMore: false,
        loadMoreFailed: true,
        onLoadMore: () => loadMoreCallCount++,
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -10000));
    await tester.pumpAndSettle();

    expect(loadMoreCallCount, 1);
  });
}
