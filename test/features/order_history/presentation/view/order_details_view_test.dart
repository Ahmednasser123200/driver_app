import 'dart:async';

import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_event.dart';
import 'package:driver_app/features/order_history/presentation/view/order_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';

void main() {
  late MockOrderDetailsCubit cubit;
  late StreamController<BaseUiEvent> events;

  setUpAll(setupFallbackValues);

  setUp(() {
    cubit = MockOrderDetailsCubit();
    events = StreamController<BaseUiEvent>.broadcast();
    stubOrderDetailsCubit(
      cubit: cubit,
      uiEventController: events,
    );
    getIt.registerFactory<OrderDetailsCubit>(() => cubit);
  });

  tearDown(() async {
    await getIt.reset();
    await events.close();
  });

  testWidgets('sends GetOrderDetailsEvent with orderId on create', (tester) async {
    await pumpApp(tester, const OrderDetailsView(orderId: 'order123'));

    verify(
      () => cubit.doIntent(
        any(
          that: isA<GetOrderDetailsEvent>().having(
            (event) => event.orderId,
            'orderId',
            'order123',
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('shows a localized SnackBar when ShowFailure is emitted', (tester) async {
    await pumpApp(tester, const OrderDetailsView(orderId: 'order123'));

    events.add(const ShowFailure(NotFoundFailure()));
    await tester.pump();
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().failureNotFound),
      findsOneWidget,
    );
  });
}
