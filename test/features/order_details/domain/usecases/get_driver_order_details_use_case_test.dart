import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockOrderDetailsRepo extends Mock implements OrderDetailsRepo {}

void main() {
  late MockOrderDetailsRepo repository;
  late GetDriverOrderDetailsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const UpdateOrderStatusParams(
        orderId: '',
        newStatus: DriverStatusUpdate.pickedUp,
      ),
    );
    registerFallbackValue(
      const ReportDriverLocationParams(lat: 0, lng: 0, recordedAt: ''),
    );
  });

  setUp(() {
    repository = MockOrderDetailsRepo();
    useCase = GetDriverOrderDetailsUseCase(repository);
  });

  group('success path', () {
    test('returns the entity produced by the repository', () async {
      final entity = buildDriverOrderDetailsEntity();
      when(
        () => repository.getOrderDetails(any()),
      ).thenAnswer((_) async => Success(entity));

      final result = await useCase.execute(kOrderId);

      expect(result, isA<Success<DriverOrderDetailsEntity>>());
      expect((result as Success<DriverOrderDetailsEntity>).data, same(entity));
    });

    test('forwards the orderId to the repository unchanged', () async {
      when(
        () => repository.getOrderDetails(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      await useCase.execute(kOrderId);

      verify(() => repository.getOrderDetails(kOrderId)).called(1);
    });

    test(
      'calls getOrderDetails exactly once and no other repo method',
      () async {
        when(
          () => repository.getOrderDetails(any()),
        ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

        await useCase.execute(kOrderId);

        verify(() => repository.getOrderDetails(any())).called(1);
        verifyNever(() => repository.updateOrderStatus(any()));
        verifyNever(() => repository.reportDriverLocation(any()));
      },
    );
  });

  group('failure path', () {
    test('returns the error emitted by the repository', () async {
      when(() => repository.getOrderDetails(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );

      final result = await useCase.execute(kOrderId);

      expect(result, isA<Error<DriverOrderDetailsEntity>>());
      expect(
        (result as Error<DriverOrderDetailsEntity>).failure,
        isA<ConflictFailure>().having(
          (f) => f.serverMessage,
          'serverMessage',
          'busy',
        ),
      );
    });

    test('does not swallow a thrown exception', () async {
      when(
        () => repository.getOrderDetails(any()),
      ).thenThrow(StateError('repo exploded'));

      await expectLater(
        () => useCase.execute(kOrderId),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('pricing orchestration', () {
    DriverOrderDetailsEntity driverPayloadWithoutPrices() =>
        buildDriverOrderDetailsEntity(
          totalPrice: null,
          currency: '',
          items: [buildOrderItemEntity(unitPrice: null)],
        );

    OrderPricingEntity pricing() => const OrderPricingEntity(
      total: 235.0,
      currency: 'EGP',
      unitPriceByProductId: {'3fa85f64-5717-4562-b3fc-2c963f66afa6': 117.5},
    );

    test('fills in the missing prices from the pricing endpoint', () async {
      when(
        () => repository.getOrderDetails(any()),
      ).thenAnswer((_) async => Success(driverPayloadWithoutPrices()));
      when(
        () => repository.getOrderPricing(any()),
      ).thenAnswer((_) async => Success(pricing()));

      final result = await useCase.execute(kOrderId);
      final data = (result as Success<DriverOrderDetailsEntity>).data;

      verify(() => repository.getOrderPricing(kOrderId)).called(1);
      expect(data.totalPrice, 235.0);
      expect(data.currency, 'EGP');
      expect(data.items.single.unitPrice, 117.5);
    });

    test(
      'never asks for pricing when every price is already present',
      () async {
        final details = Success<DriverOrderDetailsEntity>(
          buildDriverOrderDetailsEntity(),
        );
        when(
          () => repository.getOrderDetails(any()),
        ).thenAnswer((_) async => details);

        final result = await useCase.execute(kOrderId);

        expect(result, same(details));
        verify(() => repository.getOrderDetails(kOrderId)).called(1);
        verifyNever(() => repository.getOrderPricing(any()));
      },
    );

    test(
      'still asks for pricing when the total exists but an item price is missing',
      () async {
        when(() => repository.getOrderDetails(any())).thenAnswer(
          (_) async => Success(
            buildDriverOrderDetailsEntity(
              items: [buildOrderItemEntity(unitPrice: null)],
            ),
          ),
        );
        when(
          () => repository.getOrderPricing(any()),
        ).thenAnswer((_) async => Success(pricing()));

        await useCase.execute(kOrderId);

        verify(() => repository.getOrderPricing(kOrderId)).called(1);
      },
    );

    test('returns the untouched details when the pricing call fails', () async {
      final details = Success<DriverOrderDetailsEntity>(
        driverPayloadWithoutPrices(),
      );
      when(
        () => repository.getOrderDetails(any()),
      ).thenAnswer((_) async => details);
      when(() => repository.getOrderPricing(any())).thenAnswer(
        (_) async => const Error<OrderPricingEntity>(ForbiddenFailure()),
      );

      final result = await useCase.execute(kOrderId);

      expect(result, same(details));
    });

    test('does not look up pricing when the details call fails', () async {
      when(() => repository.getOrderDetails(any())).thenAnswer(
        (_) async => const Error<DriverOrderDetailsEntity>(NotFoundFailure()),
      );

      await useCase.execute(kOrderId);

      verify(() => repository.getOrderDetails(kOrderId)).called(1);
      verifyNever(() => repository.getOrderPricing(any()));
    });

    test('keeps items the pricing map does not mention', () async {
      const unknownItem = OrderItemEntity(
        productId: 'product-without-price',
        productName: 'Mystery Box',
        quantity: 1,
        unitPrice: null,
        imageUrl: '',
      );
      when(() => repository.getOrderDetails(any())).thenAnswer(
        (_) async => Success(
          buildDriverOrderDetailsEntity(
            totalPrice: null,
            currency: '',
            items: [buildOrderItemEntity(unitPrice: null), unknownItem],
          ),
        ),
      );
      when(
        () => repository.getOrderPricing(any()),
      ).thenAnswer((_) async => Success(pricing()));

      final result = await useCase.execute(kOrderId);
      final data = (result as Success<DriverOrderDetailsEntity>).data;

      expect(data.items.first.unitPrice, 117.5);
      expect(data.items.last, same(unknownItem));
    });
  });
}
