import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/widgets/available_orders_list.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
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
  });

  HomeCubit buildCubit() => HomeCubit(
    getAvailableOrdersUseCase: getOrders,
    acceptOrderUseCase: acceptOrder,
  );

  Widget buildWidget(HomeCubit cubit) {
    return wrapWithApp(
      BlocProvider<HomeCubit>.value(
        value: cubit,
        child: const Scaffold(body: AvailableOrdersList()),
      ),
    );
  }

  testWidgets('shows a loading indicator while orders are loading', (
    tester,
  ) async {
    final completer = Completer<BaseResponse<AvailableOrders>>();
    when(() => getOrders.call(page: 1)).thenAnswer((_) => completer.future);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    unawaited(cubit.doEvent(GetAvailableOrdersEvent()));
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(
      Success<AvailableOrders>(buildAvailableOrders(items: [])),
    );
    await tester.pumpAndSettle();
    expect(find.text('No orders available'), findsOneWidget);
  });

  testWidgets('shows the mapped failure message on error', (tester) async {
    when(
      () => getOrders.call(page: 1),
    ).thenAnswer((_) async => const Error<AvailableOrders>(TimeoutFailure()));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.doEvent(GetAvailableOrdersEvent());
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pump();

    final localizations = lookupAppLocalizations(const Locale('en'));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(localizations.failureTimeout), findsOneWidget);
  });

  testWidgets('shows the empty message when there are no orders', (
    tester,
  ) async {
    when(() => getOrders.call(page: 1)).thenAnswer(
      (_) async => Success<AvailableOrders>(buildAvailableOrders(items: [])),
    );
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.doEvent(GetAvailableOrdersEvent());
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pump();

    expect(find.text('No orders available'), findsOneWidget);
  });
}
