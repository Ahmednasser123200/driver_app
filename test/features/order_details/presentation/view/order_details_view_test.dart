import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:driver_app/features/order_details/data/dtos/responses/driver_order_details_response_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetDriverOrderDetailsUseCase extends Mock
    implements GetDriverOrderDetailsUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

class MockContactLauncher extends Mock implements ContactLauncher {}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockContactLauncher contactLauncher;
  late OrderDetailsCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(
        orderId: '',
        newStatus: DriverStatusUpdate.pickedUp,
      ),
    );
  });

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    contactLauncher = MockContactLauncher();
    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      contactLauncher: contactLauncher,
    );
  });

  tearDown(() {
    if (!cubit.isClosed) return cubit.close();
  });

  const deliverySuccessStub = 'Delivery succeeded';

  Future<void> pumpView(
    WidgetTester tester, {
    String orderId = kOrderId,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 700),
        builder: (context, child) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (settings) {
            if (settings.name == Routes.deliverySuccess) {
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text(deliverySuccessStub)),
              );
            }
            return null;
          },
          home: BlocProvider<OrderDetailsCubit>.value(
            value: cubit,
            child: OrderDetailsView(orderId: orderId),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }

  void mockSuccess([DriverOrderDetailsEntity? entity]) {
    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Success(entity ?? buildDriverOrderDetailsEntity()),
    );
  }

  void mockFailure() {
    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
    );
  }

  // Both address cards render call/whatsApp buttons: the pickup card reaches
  // the store and the user-address card reaches the recipient, so taps are
  // scoped to the card they belong to.
  final storeCard = find.byType(UserAddressCard).first;
  final recipientCard = find.byType(UserAddressCard).last;

  Finder callButtonIn(Finder card) => find.descendant(
    of: card,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          widget.icon is Icon &&
          (widget.icon as Icon).icon == Icons.call,
    ),
  );
  Finder whatsAppButtonIn(Finder card) => find.descendant(
    of: card,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          widget.icon is FaIcon &&
          // FaIcon.icon unwraps to the inner IconData; the public constant is a
          // FaIconData wrapper, so compare against its .data.
          (widget.icon as FaIcon).icon == FontAwesomeIcons.whatsapp.data,
    ),
  );

  final storeCallButton = callButtonIn(storeCard);
  final recipientCallButton = callButtonIn(recipientCard);
  final recipientWhatsAppButton = whatsAppButtonIn(recipientCard);

  testWidgets('requests order details when the view is built', (tester) async {
    mockSuccess();

    await pumpView(tester);
    await tester.pumpAndSettle();

    verify(() => getOrderDetails.execute(kOrderId)).called(1);
  });

  testWidgets('shows a loading indicator while waiting for data', (
    tester,
  ) async {
    when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return Success(buildDriverOrderDetailsEntity());
    });

    await pumpView(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
  });

  testWidgets('renders loaded order details', (tester) async {
    mockSuccess();

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('Order details'), findsWidgets);
    expect(find.text('ORD-12345'), findsOneWidget);
    expect(find.text('Picked'), findsOneWidget);
  });

  testWidgets(
    'renders the payload the live driver endpoint returns instead of an error',
    (tester) async {
      final entity = DriverOrderDetailsDto.fromJson(
        realDriverOrderDetailsResponse(),
      ).toDomain();
      mockSuccess(entity);

      await pumpView(tester, orderId: kRealOrderId);
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('#$kRealOrderId'), findsOneWidget);
      expect(find.text('Unknown Store'), findsOneWidget);
      expect(find.text('Store Location'), findsOneWidget);
      expect(find.text('Sarah Ahmed'), findsOneWidget);
      expect(find.text('45 El-Nahr Street, Apartment 4B'), findsOneWidget);
      expect(find.text('Glass Flower Vase'), findsOneWidget);
      expect(find.text('Red Roses Bouquet (12 Stems)'), findsOneWidget);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsNothing,
      );
      expect(find.text('Retry'), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    },
  );

  testWidgets('shows a failure message when the load fails', (tester) async {
    mockFailure();

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('The requested resource was not found.'), findsWidgets);
  });

  testWidgets('retries the request from the error state', (tester) async {
    mockFailure();

    await pumpView(tester);
    await tester.pumpAndSettle();

    mockSuccess();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('ORD-12345'), findsOneWidget);
  });

  testWidgets('keeps the action button for an order in progress', (
    tester,
  ) async {
    mockSuccess(buildDriverOrderDetailsEntity(status: OrderStatus.pickedUp));

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('Out for delivery'), findsOneWidget);
  });

  testWidgets('shows the delivery success screen once the order is Delivered', (
    tester,
  ) async {
    mockSuccess(buildDriverOrderDetailsEntity(status: OrderStatus.delivered));

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text(deliverySuccessStub), findsOneWidget);
    expect(find.byType(CustomButton), findsNothing);
  });

  testWidgets('hides the action button while the customer confirms delivery', (
    tester,
  ) async {
    mockSuccess(buildDriverOrderDetailsEntity(status: OrderStatus.arrived));

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('Arrived'), findsOneWidget);
    expect(find.byType(CustomButton), findsNothing);

    // The confirmation watcher is still polling, so stop it before the test
    // framework checks for pending timers.
    await cubit.close();
  });

  testWidgets('sends the driver status of the current step when tapped', (
    tester,
  ) async {
    mockSuccess(buildDriverOrderDetailsEntity(status: OrderStatus.pending));
    when(
      () => updateOrderStatus.execute(any()),
    ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('Picked'), findsOneWidget);

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    final params =
        verify(() => updateOrderStatus.execute(captureAny())).captured.single
            as UpdateOrderStatusParams;

    expect(params.orderId, kOrderId);
    expect(params.newStatus, DriverStatusUpdate.pickedUp);
  });

  testWidgets('renders the reloaded status after a successful update', (
    tester,
  ) async {
    var loads = 0;
    when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
      loads++;
      return Success(
        buildDriverOrderDetailsEntity(
          status: loads == 1 ? OrderStatus.outForDelivery : OrderStatus.arrived,
        ),
      );
    });
    when(
      () => updateOrderStatus.execute(any()),
    ).thenAnswer((_) async => Success(buildUpdateOrderStatusEntity()));

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('Out for delivery'), findsOneWidget);

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text('Arrived'), findsOneWidget);
    expect(find.byType(CustomButton), findsNothing);

    // Arriving at the customer starts the confirmation watcher; stop it before
    // the test framework checks for pending timers.
    await cubit.close();
  });

  testWidgets(
    'shows unknown instead of a fabricated price when the backend omits them',
    (tester) async {
      mockSuccess(
        DriverOrderDetailsDto.fromJson(
          realDriverOrderDetailsResponse(),
        ).toDomain(),
      );

      await pumpView(tester, orderId: kRealOrderId);
      await tester.pumpAndSettle();

      expect(find.text('0.00'), findsNothing);
      expect(find.text('Unknown'), findsNWidgets(3));
    },
  );

  testWidgets('renders the item price and total filled in by the pricing '
      'endpoint', (tester) async {
    mockSuccess(
      buildDriverOrderDetailsEntity(
        totalPrice: null,
        currency: '',
        items: [buildOrderItemEntity(unitPrice: null)],
      ).withPricing(
        const OrderPricingEntity(
          total: 235,
          currency: 'EGP',
          unitPriceByProductId: {'3fa85f64-5717-4562-b3fc-2c963f66afa6': 117.5},
        ),
      ),
    );

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('EGP 117.50'), findsOneWidget);
    expect(find.text('EGP 235.00'), findsOneWidget);
  });

  testWidgets('keeps the price of every item separate', (tester) async {
    mockSuccess(
      buildDriverOrderDetailsEntity(
        totalPrice: null,
        currency: 'EGP',
        items: const [
          OrderItemEntity(
            productId: 'product-a',
            productName: 'Roses',
            quantity: 1,
            unitPrice: null,
            imageUrl: '',
          ),
          OrderItemEntity(
            productId: 'product-b',
            productName: 'Vase',
            quantity: 1,
            unitPrice: null,
            imageUrl: '',
          ),
        ],
      ).withPricing(
        const OrderPricingEntity(
          total: 200,
          currency: 'EGP',
          unitPriceByProductId: {'product-a': 120, 'product-b': 80},
        ),
      ),
    );

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('EGP 120.00'), findsOneWidget);
    expect(find.text('EGP 80.00'), findsOneWidget);
  });

  testWidgets('tapping the call icon opens the recipient number', (
    tester,
  ) async {
    mockSuccess();
    when(
      () => contactLauncher.call(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.launched);

    await pumpView(tester);
    await tester.pumpAndSettle();

    await tester.tap(recipientCallButton);
    await tester.pumpAndSettle();

    verify(() => contactLauncher.call('+201012345678')).called(1);
  });

  testWidgets('tapping the whatsapp icon opens the recipient chat', (
    tester,
  ) async {
    mockSuccess();
    when(
      () => contactLauncher.whatsApp(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.launched);

    await pumpView(tester);
    await tester.pumpAndSettle();

    await tester.tap(recipientWhatsAppButton);
    await tester.pumpAndSettle();

    verify(() => contactLauncher.whatsApp('+201012345678')).called(1);
  });

  testWidgets('shows a localized message when the number is invalid', (
    tester,
  ) async {
    mockSuccess();
    when(
      () => contactLauncher.call(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.invalidNumber);

    await pumpView(tester);
    await tester.pumpAndSettle();

    await tester.tap(recipientCallButton);
    await tester.pumpAndSettle();

    expect(find.text('This contact number is not valid.'), findsOneWidget);
  });

  testWidgets('tapping the store call icon opens the pickup store number', (
    tester,
  ) async {
    mockSuccess(
      buildDriverOrderDetailsEntity(
        pickupAddress: buildPickupAddressEntity(phone: '+201234567890'),
      ),
    );
    when(
      () => contactLauncher.call(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.launched);

    await pumpView(tester);
    await tester.pumpAndSettle();

    await tester.tap(storeCallButton);
    await tester.pumpAndSettle();

    verify(() => contactLauncher.call('+201234567890')).called(1);
  });

  testWidgets('tapping the store whatsapp icon opens the shop chat', (
    tester,
  ) async {
    mockSuccess(
      buildDriverOrderDetailsEntity(
        pickupAddress: buildPickupAddressEntity(phone: '+201234567890'),
      ),
    );
    when(
      () => contactLauncher.whatsApp(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.launched);

    await pumpView(tester);
    await tester.pumpAndSettle();

    await tester.tap(whatsAppButtonIn(storeCard));
    await tester.pumpAndSettle();

    verify(() => contactLauncher.whatsApp('+201234567890')).called(1);
  });

  testWidgets('shows the line subtotal for every priced item', (tester) async {
    mockSuccess(
      buildDriverOrderDetailsEntity(
        items: [buildOrderItemEntity(unitPrice: 1500, quantity: 2)],
      ),
    );

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('Subtotal: EGP 3000.00'), findsOneWidget);
    expect(find.text('EGP 1500.00'), findsOneWidget);
  });
}
