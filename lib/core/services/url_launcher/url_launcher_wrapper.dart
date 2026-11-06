import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

@lazySingleton
class UrlLauncherWrapper {
  const UrlLauncherWrapper();

  Future<bool> launchUrl(
    Uri url, {
    url_launcher.LaunchMode mode = url_launcher.LaunchMode.platformDefault,
  }) => url_launcher.launchUrl(url, mode: mode);
}
