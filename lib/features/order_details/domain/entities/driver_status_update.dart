/// The statuses a driver can send to `PATCH /order/orders/{orderId}/status`.
///
/// The backend binds this field **by name**, e.g. `{"newStatus": "PickedUp"}`.
/// Verified against the running API:
/// - an unknown value fails to bind ->
///   `400 Failed to read parameter "UpdateOrderStatusRequestDto request" from
///   the request body as JSON.`
/// - a known but illegal step is rejected by the domain ->
///   `409 Cannot transition from 'Preparing' to 'OutForDelivery'.`
///
/// The driver flow is
/// `Preparing -> PickedUp -> OutForDelivery -> AwaitingDeliveryConfirmation`.
/// `Delivered` is a valid backend value but is not modelled here: the backend
/// resolves it to `AwaitingDeliveryConfirmation` (it is normally triggered by
/// the customer through `POST /orders/{orderId}/confirm-delivery`), so the
/// driver flow ends at [awaitingDeliveryConfirmation].
enum DriverStatusUpdate {
  /// `Preparing -> PickedUp`
  pickedUp('PickedUp'),

  /// `PickedUp -> OutForDelivery`
  outForDelivery('OutForDelivery'),

  /// `OutForDelivery -> AwaitingDeliveryConfirmation`
  awaitingDeliveryConfirmation('AwaitingDeliveryConfirmation');

  const DriverStatusUpdate(this.wireValue);

  /// The exact string the API expects in the `newStatus` field.
  final String wireValue;
}
