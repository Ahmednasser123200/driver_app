/// Normalizes a contact number into an E.164 style value (`+<country><n>`).
///
/// The payload may contain separators (`+20 100-123-4567`) or use the `00`
/// international prefix. A number without an explicit country code is rejected
/// rather than blindly prefixed, so the app never dials an unknown number.
abstract final class PhoneNumber {
  static const int _minDigits = 8;
  static const int _maxDigits = 15;

  /// Returns `+<digits>` or null when [raw] is empty, has no country code or
  /// has an implausible length.
  static String? normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final internationalPrefix = trimmed.startsWith('00');
    final hasCountryCode = trimmed.startsWith('+') || internationalPrefix;

    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (internationalPrefix && digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    if (digits.isEmpty) return null;

    if (digits.length < _minDigits || digits.length > _maxDigits) return null;

    return hasCountryCode ? '+$digits' : null;
  }

  /// Same as [normalize] but without the leading `+`, for schemes that only
  /// accept digits (e.g. `whatsapp://send?phone=`).
  static String? digitsOnly(String raw) => normalize(raw)?.substring(1);
}
