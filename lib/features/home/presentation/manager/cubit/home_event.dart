sealed class HomeEvent {
}


class GetAvailableOrdersEvent extends HomeEvent {}

class AcceptOrderEvent extends HomeEvent {
  final String orderId;
  AcceptOrderEvent(this.orderId);
}