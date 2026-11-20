import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/widgets/accept_order_button.dart';
import 'package:driver_app/features/home/presentation/widgets/available_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../home_test_fixtures.dart';

void main() {
  setUpAll(mockNetworkImages);
  tearDownAll(restoreNetworkImages);

  late MockGetAvailableOrdersUseCase getOrders;
  late MockAcceptOrderUseCase acceptOrder;

  setUp(() {
    getOrders = MockGetAvailableOrdersUseCase();
    acceptOrder = MockAcceptOrderUseCase();
  });

  Widget buildWidget(HomeCubit cubit, Widget child) {
    return wrapWithApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renders the order store, recipient and total information', (
    tester,
  ) async {
    final order = buildOrder(
      orderId: 'order-9',
      storeName: 'Flowery Store',
      storeAddress: '20th st, Giza',
      recipientName: 'Nour Mohamed',
      recipientCity: 'Giza',
      recipientArea: 'Sheikh Zayed',
      total: 3000,
    );
    final cubit = HomeCubit(
      getAvailableOrdersUseCase: getOrders,
      acceptOrderUseCase: acceptOrder,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      buildWidget(cubit, AvailableOrderCard(order: order)),
    );

    expect(find.text('Flower order'), findsOneWidget);
    expect(find.text('Pickup address'), findsOneWidget);
    expect(find.text('User address'), findsOneWidget);
    expect(find.text('Flowery Store'), findsOneWidget);
    expect(find.text('20th st, Giza'), findsOneWidget);
    expect(find.text('Nour Mohamed'), findsOneWidget);
    expect(find.text('Giza , Sheikh Zayed'), findsOneWidget);
    expect(find.text('3000.0'), findsOneWidget);
    expect(find.byType(AcceptOrderButton), findsOneWidget);
  });
}
