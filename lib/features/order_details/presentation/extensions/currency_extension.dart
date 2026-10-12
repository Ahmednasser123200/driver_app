
extension CurrencyExtension on String? {
  String get currencyLabel {
    final value = this ?? '\$';

    return value.contains('\$') ||
            value.contains('€') ||
            value.contains('£')
        ? value
        : '$value ';
  }
}
  