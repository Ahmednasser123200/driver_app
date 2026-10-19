import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/features/home/presentation/widgets/accept_order_button.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../home_test_fixtures.dart';

class _ButtonHost extends StatelessWidget {
  const _ButtonHost({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return AcceptOrderButton(
      local: AppLocalizations.of(context)!,
      orderId: orderId,
    );
  }
}

void main() {
  setUpAll(mockNetworkImages);
  tearDownAll(restoreNetworkImages);

  late MockGetAvailableOrdersUseCase getOrders;
  late MockAcceptOrderUseCase acceptOrder;

  setUp(() {
    getOrders = MockGetAvailableOrdersUseCase();
    acceptOrder = MockAcceptOrderUseCase();
  });

  HomeCubit buildCubit() => HomeCubit(
    getAvailableOrdersUseCase: getOrders,
    acceptOrderUseCase: acceptOrder,
  );

  Widget buildWidget(HomeCubit cubit, {String orderId = 'order-1'}) {
    return wrapWithApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: Scaffold(body: _ButtonHost(orderId: orderId)),
      ),
    );
  }

  ElevatedButton buttonOf(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  testWidgets('renders the localized accept label', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    expect(find.text('Accept'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('stays enabled while the active order is still unknown', (
    tester,
  ) async {
    when(
      () => acceptOrder.call('order-1'),
    ).thenAnswer((_) async => const Success<void>(null));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    // The cubit starts unresolved (activeOrderId == null), so nothing tells the
    // button to hold back: it stays pink and lets the backend decide.
    final button = buttonOf(tester);
    expect(button.onPressed, isNotNull);
    expect(button.style?.backgroundColor?.resolve(const {}), AppColors.primary);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => acceptOrder.call('order-1')).called(1);
  });

  testWidgets('shows a loader and disables the button while accepting', (
    tester,
  ) async {
    final completer = Completer<BaseResponse<void>>();
    when(() => acceptOrder.call('order-1')).thenAnswer((_) => completer.future);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    // The backend confirmed there is no active delivery: all cards enable.
    cubit.emit(const HomeState(activeOrderId: ''));
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(buttonOf(tester).onPressed, isNull);
    verify(() => acceptOrder.call('order-1')).called(1);

    completer.complete(const Success<void>(null));
    await tester.pump();
  });

  testWidgets(
    'uses the primary colour and explains the running delivery for other cards',
    (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      final events = <BaseUiEvent>[];
      final subscription = cubit.uiEventStream.listen(events.add);
      addTearDown(subscription.cancel);

      await tester.pumpWidget(buildWidget(cubit));

      cubit.emit(const HomeState(activeOrderId: 'active-order-9'));
      await tester.pump();

      final button = buttonOf(tester);
      expect(button.onPressed, isNotNull);
      expect(
        button.style?.backgroundColor?.resolve(const {}),
        AppColors.primary,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      final message = events.whereType<ShowFailureMessage>().single;
      expect(message.failure, isA<AlreadyActiveOrderFailure>());
      verifyNever(() => acceptOrder.call('order-1'));
    },
  );

  testWidgets('stays lit for the driver\'s own order and opens its details', (
    tester,
  ) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    addTearDown(subscription.cancel);

    await tester.pumpWidget(buildWidget(cubit));

    cubit.emit(const HomeState(activeOrderId: 'order-1'));
    await tester.pump();

    final button = buttonOf(tester);
    expect(button.onPressed, isNotNull);
    expect(button.style?.backgroundColor?.resolve(const {}), AppColors.primary);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    final navigation = events.whereType<NavigateTo>().single;
    expect(navigation.routeName, Routes.orderDetails);
    expect(navigation.arguments, 'order-1');
    verifyNever(() => acceptOrder.call('order-1'));
  });

  testWidgets('accepts the card order when the driver has no delivery', (
    tester,
  ) async {
    when(
      () => acceptOrder.call('order-1'),
    ).thenAnswer((_) async => const Success<void>(null));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    cubit.emit(const HomeState(activeOrderId: ''));
    await tester.pump();

    final button = buttonOf(tester);
    expect(button.onPressed, isNotNull);
    expect(button.style?.backgroundColor?.resolve(const {}), AppColors.primary);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => acceptOrder.call('order-1')).called(1);
  });
}
