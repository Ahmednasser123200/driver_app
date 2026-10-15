import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_event.dart';
import 'package:driver_app/features/home/presentation/view/home_driver_view.dart';
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
        child: const HomeDriverView(),
      ),
    );
  }

  testWidgets('renders the app title and the orders list', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));
    await tester.pump();

    final localizations = lookupAppLocalizations(const Locale('en'));
    expect(find.text(localizations.appName), findsOneWidget);
    expect(find.byType(AvailableOrdersList), findsOneWidget);
    expect(find.text('No orders available'), findsOneWidget);
  });

  testWidgets('shows the loading indicator on first load', (tester) async {
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
  });
}
