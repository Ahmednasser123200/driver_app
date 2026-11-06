abstract interface class UrlLauncherService {
  Future<bool> callPhone(String phoneNumber);

  Future<bool> openWhatsApp(String phoneNumber);
}
