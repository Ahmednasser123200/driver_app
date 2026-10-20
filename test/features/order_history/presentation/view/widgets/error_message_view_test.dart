import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/error_message_view.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('shows localized timeout message', (tester) async {
    await pumpApp(tester, const ErrorMessageView(failure: TimeoutFailure()));

    expect(find.text(l10n.failureTimeout), findsOneWidget);
  });

  testWidgets('shows localized internet connection message', (tester) async {
    await pumpApp(
      tester,
      const ErrorMessageView(failure: InternetConnectionFailure()),
    );

    expect(find.text(l10n.failureInternetConnection), findsOneWidget);
  });

  testWidgets('shows localized not found message', (tester) async {
    await pumpApp(tester, const ErrorMessageView(failure: NotFoundFailure()));

    expect(find.text(l10n.failureNotFound), findsOneWidget);
  });

  testWidgets('shows server message for BadRequestFailure', (tester) async {
    await pumpApp(
      tester,
      const ErrorMessageView(
        failure: BadRequestFailure(serverMessage: 'Server rejected the request'),
      ),
    );

    expect(find.text('Server rejected the request'), findsOneWidget);
  });

  testWidgets('falls back to localized message for empty server message', (tester) async {
    await pumpApp(
      tester,
      const ErrorMessageView(failure: BadRequestFailure(serverMessage: '')),
    );

    expect(find.text(l10n.failureBadRequest), findsOneWidget);
  });
}
