import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/features/order_history/api/client/order_history_api_client.dart';
import 'package:driver_app/features/order_history/data/data_source/order_history_remote_data_source.dart';
import 'package:driver_app/features/order_history/data/model/order_history_request_dto.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/repo/order_history_repo.dart';
import 'package:driver_app/features/order_history/domain/use_case/get_order_details_use_case.dart';
import 'package:driver_app/features/order_history/domain/use_case/get_orders_use_case.dart';
import 'package:driver_app/features/order_history/domain/use_case/watch_order_updates_use_case.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderHistoryApiClient extends Mock implements OrderHistoryApiClient {}

class MockOrderHistoryRemoteDataSource extends Mock
    implements OrderHistoryRemoteDataSource {}

class MockOrderHistoryRepo extends Mock implements OrderHistoryRepo {}

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}

class MockWatchOrderUpdatesUseCase extends Mock
    implements WatchOrderUpdatesUseCase {}

class MockOrdersCubit extends MockCubit<OrdersState> implements OrdersCubit {}

class MockOrderDetailsCubit extends MockCubit<OrderDetailsState>
    implements OrderDetailsCubit {}

void setupFallbackValues() {
  registerFallbackValue(LoadOrdersEvent());
  registerFallbackValue(LoadMoreOrdersEvent());
  registerFallbackValue(ToggleStatusFilterEvent(OrderStatus.completed));
  registerFallbackValue(GetOrderDetailsEvent(orderId: '123'));
  registerFallbackValue(
    const OrderHistoryRequestDto(page: 1, pageSize: 10),
  );
  registerFallbackValue(OrderStatus.completed);
}

void stubOrdersCubit({
  required MockOrdersCubit cubit,
  OrdersState state = const OrdersState(),
  StreamController<BaseUiEvent>? uiEventController,
}) {
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.doIntent(any())).thenAnswer((_) async {});
  when(() => cubit.uiEventStream).thenAnswer(
    (_) => uiEventController?.stream ?? const Stream<BaseUiEvent>.empty(),
  );
}

void stubOrderDetailsCubit({
  required MockOrderDetailsCubit cubit,
  OrderDetailsState state = const OrderDetailsState(),
  StreamController<BaseUiEvent>? uiEventController,
}) {
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.doIntent(any())).thenAnswer((_) async {});
  when(() => cubit.uiEventStream).thenAnswer(
    (_) => uiEventController?.stream ?? const Stream<BaseUiEvent>.empty(),
  );
}
