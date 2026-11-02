part of '../../../../../../config/base/base_ui_event.dart';

sealed class OrderDetailsUiEvent extends BaseUiEvent {
  const OrderDetailsUiEvent();
}

class ShowOrderStatusUpdated extends OrderDetailsUiEvent {
  const ShowOrderStatusUpdated();
}

class ShowOrderDetailsFailure extends OrderDetailsUiEvent {
  final AppFailure failure;

  const ShowOrderDetailsFailure(this.failure);
}
