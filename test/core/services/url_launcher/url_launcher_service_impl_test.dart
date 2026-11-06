import 'package:driver_app/core/services/url_launcher/url_launcher_service_impl.dart';
import 'package:driver_app/core/services/url_launcher/url_launcher_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher.dart';

class MockUrlLauncherWrapper extends Mock implements UrlLauncherWrapper {}

void main() {
  late MockUrlLauncherWrapper mockWrapper;
  late UrlLauncherServiceImpl service;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(LaunchMode.platformDefault);
  });

  setUp(() {
    mockWrapper = MockUrlLauncherWrapper();
    service = UrlLauncherServiceImpl(mockWrapper);
  });

  group('UrlLauncherServiceImpl', () {
    test('callPhone sanitizes spaces and launches tel URI', () async {
      when(
        () => mockWrapper.launchUrl(
          any(),
          mode: LaunchMode.externalApplication,
        ),
      ).thenAnswer((_) async => true);

      final result = await service.callPhone('+20 100 000 0000');

      expect(result, isTrue);
      verify(
        () => mockWrapper.launchUrl(
          Uri(scheme: 'tel', path: '+201000000000'),
          mode: LaunchMode.externalApplication,
        ),
      ).called(1);
    });

    test('callPhone returns false when phone number is blank', () async {
      final result = await service.callPhone('   ');
      expect(result, isFalse);
      verifyNever(() => mockWrapper.launchUrl(any(), mode: any(named: 'mode')));
    });

    test('openWhatsApp strips non-digits and launches wa.me URI', () async {
      when(
        () => mockWrapper.launchUrl(
          any(),
          mode: LaunchMode.externalApplication,
        ),
      ).thenAnswer((_) async => true);

      final result = await service.openWhatsApp('+20-101-111-1111');

      expect(result, isTrue);
      verify(
        () => mockWrapper.launchUrl(
          Uri.parse('https://wa.me/201011111111'),
          mode: LaunchMode.externalApplication,
        ),
      ).called(1);
    });

    test('returns false when wrapper throws an exception', () async {
      when(
        () => mockWrapper.launchUrl(
          any(),
          mode: LaunchMode.externalApplication,
        ),
      ).thenThrow(Exception('launch failed'));

      expect(await service.callPhone('+201000000000'), isFalse);
      expect(await service.openWhatsApp('+201000000000'), isFalse);
    });
  });
}
