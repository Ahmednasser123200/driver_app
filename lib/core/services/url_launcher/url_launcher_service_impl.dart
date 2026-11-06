import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'url_launcher_service.dart';
import 'url_launcher_wrapper.dart';

@LazySingleton(as: UrlLauncherService)
class UrlLauncherServiceImpl implements UrlLauncherService {
  final UrlLauncherWrapper _urlLauncherWrapper;

  const UrlLauncherServiceImpl(this._urlLauncherWrapper);

  @override
  Future<bool> callPhone(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.isEmpty) return false;

    final uri = Uri(scheme: 'tel', path: cleanNumber);
    return _launchExternal(uri);
  }

  @override
  Future<bool> openWhatsApp(String phoneNumber) async {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return false;

    final uri = Uri.parse('https://wa.me/$digitsOnly');
    return _launchExternal(uri);
  }

  Future<bool> _launchExternal(Uri uri) async {
    try {
      return await _urlLauncherWrapper.launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
