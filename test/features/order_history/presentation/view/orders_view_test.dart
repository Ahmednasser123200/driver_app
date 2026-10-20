import 'dart:async';

import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/view/orders_view.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';

void main() {
  late MockOrdersCubit cubit;
  late StreamController<BaseUiEvent> events;

  setUpAll(setupFallbackValues);

  setUp(() {
    cubit = MockOrdersCubit();
    events = StreamController<BaseUiEvent>.broadcast();
    stubOrdersCubit(
      cubit: cubit,
      uiEventController: events,
    );
    getIt.registerFactory<OrdersCubit>(() => cubit);
  });

  tearDown(() async {
    await getIt.reset();
    await events.close();
  });

  testWidgets('sends LoadOrdersEvent on create', (tester) async {
    await pumpApp(tester, const OrdersView());

    verify(() => cubit.doIntent(any(that: isA<LoadOrdersEvent>()))).called(1);
  });

  testWidgets('shows a localized SnackBar when ShowFailure is emitted', (tester) async {
    await pumpApp(tester, const OrdersView());

    events.add(const ShowFailure(TimeoutFailure()));
    await tester.pump();
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().failureTimeout),
      findsOneWidget,
    );
  });
}
