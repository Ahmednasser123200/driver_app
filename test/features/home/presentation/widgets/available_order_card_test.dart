import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/features/home/presentation/widgets/accept_order_button.dart';
import 'package:driver_app/features/home/presentation/widgets/available_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../home_test_fixtures.dart';

void main() {
  setUpAll(mockNetworkImages);
  tearDownAll(restoreNetworkImages);

  late MockGetAvailableOrdersUseCase getOrders;
  late MockAcceptOrderUseCase acceptOrder;

  setUp(() {
    getOrders = MockGetAvailableOrdersUseCase();
    acceptOrder = MockAcceptOrderUseCase();
    when(
      () => acceptOrder.getActiveOrderId(),
    ).thenAnswer((_) async => const Success<String>(''));
  });

  Widget buildWidget(HomeCubit cubit, Widget child) {
    return wrapWithApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: Scaffold(body: child),
      ),
    );
  }

  // The cards are tall: give the surface enough room for three of them so
  // every button is laid out and tappable.
  void enlargeSurface(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 1800);
    addTearDown(tester.view.reset);
  }

  Widget cardRow() => Column(
    children: [
      AvailableOrderCard(
        key: const ValueKey('order-1'),
        order: buildOrder(orderId: 'order-1'),
      ),
      AvailableOrderCard(
        key: const ValueKey('order-2'),
        order: buildOrder(orderId: 'order-2'),
      ),
      AvailableOrderCard(
        key: const ValueKey('order-3'),
        order: buildOrder(orderId: 'order-3'),
      ),
    ],
  );

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

  testWidgets(
    'with no active order every card is enabled and tapping uses its own id',
    (tester) async {
      enlargeSurface(tester);
      when(
        () => acceptOrder.call(any()),
      ).thenAnswer((_) async => const Success<void>(null));
      final cubit = HomeCubit(
        getAvailableOrdersUseCase: getOrders,
        acceptOrderUseCase: acceptOrder,
      );
      addTearDown(cubit.close);
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);
      addTearDown(subscription.cancel);

      await tester.pumpWidget(buildWidget(cubit, cardRow()));

      // The backend confirmed there is no active delivery: every button is on.
      cubit.emit(const HomeState(activeOrderId: ''));
      await tester.pump();

      final buttons = tester
          .widgetList<ElevatedButton>(find.byType(ElevatedButton))
          .toList();
      expect(buttons, hasLength(3));
      for (final button in buttons) {
        expect(button.onPressed, isNotNull);
      }

      // Tap the middle card: its own id must be the one accepted.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('order-2')),
          matching: find.byType(AcceptOrderButton),
        ),
      );
      await tester.pump();

      verify(() => acceptOrder.call('order-2')).called(1);
      verifyNever(() => acceptOrder.call('order-1'));
      verifyNever(() => acceptOrder.call('order-3'));
    },
  );

  testWidgets('with a running delivery the driver re-opens their own order', (
    tester,
  ) async {
    enlargeSurface(tester);
    final cubit = HomeCubit(
      getAvailableOrdersUseCase: getOrders,
      acceptOrderUseCase: acceptOrder,
    );
    addTearDown(cubit.close);
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    addTearDown(subscription.cancel);

    await tester.pumpWidget(buildWidget(cubit, cardRow()));

    cubit.emit(const HomeState(activeOrderId: 'order-2'));
    await tester.pump();

    final buttons = tester
        .widgetList<ElevatedButton>(find.byType(ElevatedButton))
        .toList();
    expect(buttons, hasLength(3));
    // Every card keeps the primary colour; only the driver's own order opens.
    for (final button in buttons) {
      expect(button.onPressed, isNotNull);
      expect(
        button.style?.backgroundColor?.resolve(const {}),
        AppColors.primary,
      );
    }

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('order-2')),
        matching: find.byType(AcceptOrderButton),
      ),
    );
    await tester.pump();

    final navigation = events.whereType<NavigateTo>().single;
    expect(navigation.routeName, Routes.orderDetails);
    expect(navigation.arguments, 'order-2');
    verifyNever(() => acceptOrder.call(any()));
  });

  testWidgets('with a running delivery other cards explain it and refuse', (
    tester,
  ) async {
    enlargeSurface(tester);
    final cubit = HomeCubit(
      getAvailableOrdersUseCase: getOrders,
      acceptOrderUseCase: acceptOrder,
    );
    addTearDown(cubit.close);
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    addTearDown(subscription.cancel);

    await tester.pumpWidget(buildWidget(cubit, cardRow()));

    cubit.emit(const HomeState(activeOrderId: 'order-2'));
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('order-1')),
        matching: find.byType(AcceptOrderButton),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    final message = events.whereType<ShowFailureMessage>().single;
    expect(message.failure, isA<AlreadyActiveOrderFailure>());
    verifyNever(() => acceptOrder.call(any()));
    expect(events.whereType<NavigateTo>(), isEmpty);
    expect(events.whereType<NavigateRepalceTo>(), isEmpty);
  });
}
