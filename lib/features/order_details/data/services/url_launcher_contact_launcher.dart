import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
import 'package:driver_app/features/order_details/domain/utils/phone_number.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the OS dialer / WhatsApp through `url_launcher`.
@Injectable(as: ContactLauncher)
class UrlLauncherContactLauncher implements ContactLauncher {
  const UrlLauncherContactLauncher();

  @override
  Future<ContactLaunchOutcome> call(String phoneRaw) async {
    final number = PhoneNumber.normalize(phoneRaw);
    if (number == null) return ContactLaunchOutcome.invalidNumber;

    return _launch(Uri(scheme: 'tel', path: number));
  }

  @override
  Future<ContactLaunchOutcome> whatsApp(String phoneRaw) async {
    final number = PhoneNumber.digitsOnly(phoneRaw);
    if (number == null) return ContactLaunchOutcome.invalidNumber;

    // The app scheme works only when WhatsApp is installed, so fall back to the
    // universal web link before reporting it unavailable.
    final appOutcome = await _launch(
      Uri.parse('whatsapp://send?phone=$number'),
    );
    if (appOutcome == ContactLaunchOutcome.launched) return appOutcome;

    final webOutcome = await _launch(Uri.parse('https://wa.me/$number'));
    if (webOutcome == ContactLaunchOutcome.launched) {
      return ContactLaunchOutcome.launched;
    }

    return ContactLaunchOutcome.whatsAppUnavailable;
  }

  Future<ContactLaunchOutcome> _launch(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched
          ? ContactLaunchOutcome.launched
          : ContactLaunchOutcome.failed;
    } on Object {
      return ContactLaunchOutcome.failed;
    }
  }
}
