import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_state.dart';
import 'package:driver_app/features/home/presentation/widgets/active_order_button.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../home_test_fixtures.dart';

const label = 'View Active Order';

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

  HomeCubit buildCubit() => HomeCubit(
    getAvailableOrdersUseCase: getOrders,
    acceptOrderUseCase: acceptOrder,
  );

  Widget buildWidget(HomeCubit cubit) {
    return wrapWithApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: const Scaffold(body: ActiveOrderButton()),
      ),
    );
  }

  testWidgets('shows a primary button only for a confirmed active order', (
    tester,
  ) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    // Unresolved (loading or failed lookup): no button at all.
    expect(find.text(label), findsNothing);

    cubit.emit(const HomeState(activeOrderId: 'active-order-9'));
    await tester.pumpAndSettle();

    expect(find.text(label), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style?.backgroundColor?.resolve(const {}), AppColors.primary);
  });

  testWidgets('navigates to the exact active order without accepting', (
    tester,
  ) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    final events = <BaseUiEvent>[];
    final subscription = cubit.uiEventStream.listen(events.add);
    addTearDown(subscription.cancel);

    await tester.pumpWidget(buildWidget(cubit));

    cubit.emit(const HomeState(activeOrderId: 'active-order-9'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(label));
    await tester.pumpAndSettle();

    final navigation = events.whereType<NavigateTo>().single;
    expect(navigation.routeName, Routes.orderDetails);
    expect(navigation.arguments, 'active-order-9');
    expect(events.whereType<NavigateRepalceTo>(), isEmpty);
    expect(events.whereType<ShowFailureMessage>(), isEmpty);
    verifyNever(() => acceptOrder.call(any()));
  });

  testWidgets('hides the button once the backend confirms there is none', (
    tester,
  ) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    cubit.emit(const HomeState(activeOrderId: ''));
    await tester.pumpAndSettle();

    expect(find.text(label), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(tester.getSize(find.byType(ActiveOrderButton)), Size.zero);
  });

  testWidgets('stays hidden when a failed lookup leaves the state unresolved', (
    tester,
  ) async {
    when(
      () => getOrders.call(page: 1),
    ).thenAnswer((_) async => Success<AvailableOrders>(buildAvailableOrders()));
    when(
      () => acceptOrder.getActiveOrderId(),
    ).thenAnswer((_) async => const Error<String>(ServerFailure()));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    await cubit.doEvent(GetAvailableOrdersEvent());
    await tester.pumpAndSettle();

    // A failed lookup is not proof of absence: the button stays hidden.
    expect(cubit.state.activeOrderId, isNull);
    expect(find.text(label), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('disappears as soon as the active order is cleared', (
    tester,
  ) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    cubit.emit(const HomeState(activeOrderId: 'active-order-9'));
    await tester.pumpAndSettle();
    expect(find.text(label), findsOneWidget);

    // Order completed (or the session changed): the stale shortcut must go.
    cubit.emit(const HomeState(activeOrderId: ''));
    await tester.pumpAndSettle();

    expect(find.text(label), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('uses the localized label', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    cubit.emit(const HomeState(activeOrderId: 'active-order-9'));
    await tester.pumpAndSettle();

    final localizations = lookupAppLocalizations(const Locale('en'));
    expect(find.text(localizations.viewActiveOrder), findsOneWidget);
  });
}
