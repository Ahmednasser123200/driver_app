/// Abstraction over opening the dialer / WhatsApp so the order details flow can
/// be tested without touching platform channels.
abstract interface class ContactLauncher {
  Future<ContactLaunchOutcome> call(String phoneRaw);
  Future<ContactLaunchOutcome> whatsApp(String phoneRaw);
}

enum ContactLaunchOutcome {
  /// The external app took over.
  launched,

  /// The number is empty, has no country code or has an implausible length.
  invalidNumber,

  /// WhatsApp could not be reached (scheme refused and the web fallback failed).
  whatsAppUnavailable,

  /// The OS refused to open the dialer.
  failed,
}
