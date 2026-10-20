abstract interface class ApiEnvelope<T> {
  bool get isOk;
  String get message;
  T? get data;
}
