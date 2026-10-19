sealed class HomeEvent {}

class GetAvailableOrdersEvent extends HomeEvent {}

class AcceptOrderEvent extends HomeEvent {
  final String orderId;
  AcceptOrderEvent(this.orderId);
}

class OpenOrderDetailsEvent extends HomeEvent {
  final String orderId;
  OpenOrderDetailsEvent(this.orderId);
}

class LoadMoreOrdersEvent extends HomeEvent {}

/// Re-reads which order the driver currently has (id only, no list reload)
/// after returning from a screen where the order may have been completed.
class RefreshActiveOrderEvent extends HomeEvent {}
