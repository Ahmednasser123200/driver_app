import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/presentation/manager/cubit/home_cubit.dart';
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

  testWidgets('renders the localized accept label', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    expect(find.text('Accept'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a loader and disables the button while accepting', (
    tester,
  ) async {
    final completer = Completer<BaseResponse<void>>();
    when(() => acceptOrder.call('order-1')).thenAnswer((_) => completer.future);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    verify(() => acceptOrder.call('order-1')).called(1);

    completer.complete(const Success<void>(null));
    await tester.pump();
  });

  testWidgets('re-enables the button after the request completes', (
    tester,
  ) async {
    when(
      () => acceptOrder.call('order-1'),
    ).thenAnswer((_) async => const Success<void>(null));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildWidget(cubit));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Accept'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });
}
