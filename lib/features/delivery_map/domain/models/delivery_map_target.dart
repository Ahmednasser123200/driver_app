enum DeliveryMapTarget {
  pickup,
  user;

  bool get isPickup => this == DeliveryMapTarget.pickup;
  bool get isUser => this == DeliveryMapTarget.user;
}
